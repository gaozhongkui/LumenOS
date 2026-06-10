import SwiftUI
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    let productID = "com.lumenos.pro.unlock"

    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var products: [StoreKit.Product] = []

    @Published var flashlightUsageCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(flashlightUsageCount, forKey: "flashlight_usage_count")
        }
    }

    @Published var barrageUsageCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(barrageUsageCount, forKey: "barrage_usage_count")
        }
    }

    private var updateListenerTask: Task<Void, Never>? = nil

    private init() {
        self.isSubscribed = UserDefaults.standard.bool(forKey: "is_subscribed")
        self.flashlightUsageCount = UserDefaults.standard.integer(forKey: "flashlight_usage_count")
        self.barrageUsageCount = UserDefaults.standard.integer(forKey: "barrage_usage_count")

        updateListenerTask = listenForTransactions()

        Task {
            await fetchProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func fetchProducts() async {
        do {
            self.products = try await StoreKit.Product.products(for: [productID])
        } catch {
            print("StoreKit: Fetch products failed: \(error)")
        }
    }

    func purchase() async throws {
        guard let product = products.first else { return }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            _ = try checkVerified(verification)
            await updatePurchaseStatus()
            if case .verified(let transaction) = verification {
                await transaction.finish()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    func updatePurchaseStatus() async {
        var hasActivePurchase = false
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    hasActivePurchase = true
                    break
                }
            }
        }
        self.isSubscribed = hasActivePurchase
        UserDefaults.standard.set(hasActivePurchase, forKey: "is_subscribed")
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    // Transaction here refers to StoreKit.Transaction.updates
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                } catch {
                    print("StoreKit: Transaction update verification failed")
                }
            }
        }
    }

    // 关键修复：使用 nonisolated 允许从后台任务调用，并明确指定 StoreKit 命名空间
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    func canUseFlashlight() -> Bool {
        isSubscribed || flashlightUsageCount < 2
    }

    func recordFlashlightUsage() {
        if !isSubscribed {
            flashlightUsageCount += 1
        }
    }

    func canUseBarrage() -> Bool {
        isSubscribed || barrageUsageCount < 2
    }

    func recordBarrageUsage() {
        if !isSubscribed {
            barrageUsageCount += 1
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
