import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

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
        .accentColor(.yellow)
        .preferredColorScheme(.dark)
    }
}

struct ProfileView: View {
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(NSLocalizedString("user_name_default", comment: ""))
                                    .font(.headline)
                                if subManager.isSubscribed {
                                    Text(NSLocalizedString("badge_pro", comment: ""))
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow)
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

                Section(header: Text(NSLocalizedString("section_account_status", comment: ""))) {
                    HStack {
                        Label(NSLocalizedString("pro_status_title", comment: ""), systemImage: "crown.fill")
                            .foregroundColor(subManager.isSubscribed ? .yellow : .gray)
                        Spacer()
                        Text(subManager.isSubscribed ? NSLocalizedString("status_activated", comment: "") : NSLocalizedString("status_not_unlocked", comment: ""))
                            .foregroundColor(.gray)
                    }

                    if !subManager.isSubscribed {
                        Button(action: { showPaywall = true }) {
                            Text(NSLocalizedString("btn_unlock_pro", comment: ""))
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                        }
                    } else {
                        HStack {
                            Text(NSLocalizedString("thanks_support", comment: ""))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text(NSLocalizedString("section_legal", comment: ""))) {
                    NavigationLink(destination: Text(NSLocalizedString("privacy_policy_content", comment: ""))) {
                        Label(NSLocalizedString("privacy_policy", comment: ""), systemImage: "shield.lefthalf.filled")
                    }

                    NavigationLink(destination: Text(NSLocalizedString("terms_of_service_content", comment: ""))) {
                        Label(NSLocalizedString("terms_of_service", comment: ""), systemImage: "doc.text")
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            await subManager.updatePurchaseStatus()
                        }
                    }) {
                        Text(NSLocalizedString("btn_restore_purchase", comment: ""))
                            .frame(maxWidth: .infinity)
                            .alignmentGuide(.leading) { _ in 0 }
                    }
                    .foregroundColor(.gray)
                }
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
