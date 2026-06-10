import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.08, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = .gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            FlashlightView()
                .tabItem {
                    Label(NSLocalizedString("tab_flashlight", comment: ""), systemImage: "flashlight.on.fill")
                }
                .tag(0)

            BarrageView()
                .tabItem {
                    Label(NSLocalizedString("tab_barrage", comment: ""), systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab_profile", comment: ""), systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(themeManager.selectedTheme.primary)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Document View
struct DocumentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(content)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .background(themeManager.selectedTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.selectedTheme.background.ignoresSafeArea()

                List {
                    // User Info
                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(themeManager.selectedTheme.primary.opacity(0.8))

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(NSLocalizedString("user_name_default", comment: ""))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    if subManager.isSubscribed {
                                        Text(NSLocalizedString("badge_pro", comment: ""))
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(LinearGradient(colors: [themeManager.selectedTheme.primary, themeManager.selectedTheme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .foregroundColor(.black)
                                            .cornerRadius(4)
                                    }
                                }
                                Text("ID: 88889999")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)

                    // MARK: - Skin Selection Section
                    Section(header: Text("APP SKIN").foregroundColor(.gray)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(AppTheme.allCases) { theme in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(theme.primary)
                                                .frame(width: 45, height: 45)

                                            if themeManager.selectedTheme == theme {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 20, weight: .bold))
                                            } else if theme.isPro && !subManager.isSubscribed {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.black.opacity(0.5))
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        .onTapGesture {
                                            if theme.isPro && !subManager.isSubscribed {
                                                showPaywall = true
                                            } else {
                                                withAnimation {
                                                    themeManager.selectedTheme = theme
                                                }
                                            }
                                        }

                                        Text(theme.rawValue)
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)

                    // Subscription
                    Section(header: Text(NSLocalizedString("section_account_status", comment: "")).foregroundColor(.gray)) {
                        HStack {
                            Label(NSLocalizedString("pro_status_title", comment: ""), systemImage: "crown.fill")
                                .foregroundColor(subManager.isSubscribed ? themeManager.selectedTheme.primary : .gray)
                            Spacer()
                            Text(subManager.isSubscribed ? NSLocalizedString("status_activated", comment: "") : NSLocalizedString("status_not_unlocked", comment: ""))
                                .foregroundColor(.gray)
                        }

                        if !subManager.isSubscribed {
                            Button(action: { showPaywall = true }) {
                                Text(NSLocalizedString("btn_unlock_pro", comment: ""))
                                    .foregroundColor(themeManager.selectedTheme.primary)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)

                    // Legal & Info
                    Section(header: Text(NSLocalizedString("section_legal", comment: "")).foregroundColor(.gray)) {
                        NavigationLink(destination: DocumentView(title: "Product Info", content: productIntroText)) {
                            Label("Product Info", systemImage: "info.circle")
                        }

                        NavigationLink(destination: DocumentView(title: NSLocalizedString("privacy_policy", comment: ""), content: privacyPolicyText)) {
                            Label(NSLocalizedString("privacy_policy", comment: ""), systemImage: "shield.lefthalf.filled")
                        }

                        NavigationLink(destination: DocumentView(title: NSLocalizedString("terms_of_service", comment: ""), content: termsOfServiceText)) {
                            Label(NSLocalizedString("terms_of_service", comment: ""), systemImage: "doc.text")
                        }
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)

                    Section {
                        Button(action: {
                            Task { await subManager.updatePurchaseStatus() }
                        }) {
                            Text(NSLocalizedString("btn_restore_purchase", comment: ""))
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.gray)
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(NSLocalizedString("tab_profile", comment: ""))
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
            }
        }
    }

    private var productIntroText: String = """
    LumenOS is an all-in-one light and shadow tool.

    - Intelligent Flashlight: Precision brightness control with SOS and Party modes.
    - Creative Barrage: Custom LED effects with RGB glow and dynamic themes.
    - Sync Feature: Synchronize your flashlight with your barrage rhythm.

    Unlock PRO to enjoy unlimited features and exclusive themes.
    """

    private var privacyPolicyText: String = """
    Your privacy is our priority.

    1. No Collection: We do not collect any personal data or location information.
    2. Permissions: Camera/Flashlight access is used only for lighting features.
    3. Security: All processing is done locally on your device.
    """

    private var termsOfServiceText: String = """
    By using LumenOS, you agree to these terms:

    - License: Personal, non-commercial use only.
    - Purchase: PRO features are available via a one-time payment.
    - Responsibility: We are not liable for misuse of the flashlight features.
    """
}

#Preview {
    ContentView().environmentObject(ThemeManager.shared)
}
