import SwiftUI

// MARK: - Brand Color Palette
extension Color {
    static let l_background = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let l_surface = Color(red: 0.11, green: 0.12, blue: 0.16)
    static let l_gold = Color(red: 1.00, green: 0.84, blue: 0.29) // 品牌金：来源于图标
    static let l_accent = Color(red: 1.00, green: 0.58, blue: 0.00) // 品牌橙：辅助渐变
}

struct ContentView: View {
    @State private var selectedTab = 0

    init() {
        // 自定义 TabBar 外观
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.l_background)
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
        .accentColor(.l_gold)
        .preferredColorScheme(.dark)
    }
}

struct ProfileView: View {
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.l_background.ignoresSafeArea()

                List {
                    Section {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.l_gold.opacity(0.8))

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
                                            .background(LinearGradient(colors: [.l_gold, .l_accent], startPoint: .topLeading, endPoint: .bottomTrailing))
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
                    .listRowBackground(Color.l_surface)

                    Section(header: Text(NSLocalizedString("section_account_status", comment: "")).foregroundColor(.gray)) {
                        HStack {
                            Label(NSLocalizedString("pro_status_title", comment: ""), systemImage: "crown.fill")
                                .foregroundColor(subManager.isSubscribed ? .l_gold : .gray)
                            Spacer()
                            Text(subManager.isSubscribed ? NSLocalizedString("status_activated", comment: "") : NSLocalizedString("status_not_unlocked", comment: ""))
                                .foregroundColor(.gray)
                        }

                        if !subManager.isSubscribed {
                            Button(action: { showPaywall = true }) {
                                Text(NSLocalizedString("btn_unlock_pro", comment: ""))
                                    .foregroundColor(.l_gold)
                                    .fontWeight(.bold)
                            }
                        } else {
                            Text(NSLocalizedString("thanks_support", comment: ""))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.l_surface)

                    Section(header: Text(NSLocalizedString("section_legal", comment: "")).foregroundColor(.gray)) {
                        NavigationLink(destination: Text(NSLocalizedString("privacy_policy_content", comment: ""))) {
                            Label(NSLocalizedString("privacy_policy", comment: ""), systemImage: "shield.lefthalf.filled")
                        }

                        NavigationLink(destination: Text(NSLocalizedString("terms_of_service_content", comment: ""))) {
                            Label(NSLocalizedString("terms_of_service", comment: ""), systemImage: "doc.text")
                        }
                    }
                    .listRowBackground(Color.l_surface)

                    Section {
                        Button(action: {
                            Task {
                                await subManager.updatePurchaseStatus()
                            }
                        }) {
                            Text(NSLocalizedString("btn_restore_purchase", comment: ""))
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.l_surface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(NSLocalizedString("tab_profile", comment: ""))
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
            }
        }
    }
}

#Preview {
    ContentView()
}
