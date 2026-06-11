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



struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var webURL: URL? = nil

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
                                Text(subManager.isSubscribed
                                     ? NSLocalizedString("status_activated", comment: "")
                                     : NSLocalizedString("status_not_unlocked", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(themeManager.selectedTheme.surface)

                    // MARK: - Skin Selection Section
                    Section(header: Text(NSLocalizedString("section_app_skin", comment: "")).foregroundColor(.gray)) {
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
                        Button {
                            webURL = URL(string: "https://gaozhongkui.github.io/zhongkuitech/LumenOS/")
                        } label: {
                            Label(NSLocalizedString("product_info", comment: ""), systemImage: "info.circle")
                        }

                        Button {
                            webURL = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRQgj2bHW_bPvVIPPRJWeeCknPYo5TqWBM9UPqjRuizwK98fxFZ1wl7H1mYUgnwzc45Zh5Glvc8igZI/pub")
                        } label: {
                            Label(NSLocalizedString("privacy_policy", comment: ""), systemImage: "shield.lefthalf.filled")
                        }

                        Button {
                            webURL = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRulMM4KmyJvKzz9zaTQECGJJESVmFN-h7F-ke5tst4qYDWzGpYGAVy0fBJXlQifLgSSRxZxyI5r7Zk/pub")
                        } label: {
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
            .sheet(item: $webURL) { url in
                WebBrowserView(title: url.host ?? "", url: url)
            }
        }
    }

}

#Preview {
    ContentView().environmentObject(ThemeManager.shared)
}
