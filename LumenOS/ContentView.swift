import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FlashlightView()
                .tabItem {
                    Label("手电筒", systemImage: "flashlight.on.fill")
                }
                .tag(0)

            BarrageView()
                .tabItem {
                    Label("弹幕", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.yellow)
        .preferredColorScheme(.dark)
    }
}

// 完善后的“我的”页面
struct ProfileView: View {
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            List {
                // 用户信息头部
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lumen 用户")
                                .font(.headline)
                            Text("ID: 88889999")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if subManager.isSubscribed {
                            Text("PRO")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // 订阅状态及购买
                Section(header: Text("账号状态")) {
                    HStack {
                        Label("永久专业版", systemImage: "crown.fill")
                            .foregroundColor(subManager.isSubscribed ? .yellow : .gray)
                        Spacer()
                        Text(subManager.isSubscribed ? "已激活" : "未解锁")
                            .foregroundColor(.gray)
                    }

                    if !subManager.isSubscribed {
                        Button(action: { showPaywall = true }) {
                            Text("立即解锁专业版 ($0.99)")
                                .foregroundColor(.yellow)
                                .fontWeight(.bold)
                        }
                    } else {
                        HStack {
                            Text("感谢支持！您已解锁所有功能")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text("法律信息")) {
                    NavigationLink(destination: Text("隐私协议内容...")) {
                        Label("隐私协议", systemImage: "shield.lefthalf.filled")
                    }

                    NavigationLink(destination: Text("服务条款内容...")) {
                        Label("服务条款", systemImage: "doc.text")
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            await subManager.updatePurchaseStatus()
                        }
                    }) {
                        Text("恢复购买")
                            .frame(maxWidth: .infinity)
                            .alignmentGuide(.leading) { _ in 0 }
                    }
                    .foregroundColor(.gray)
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
            }
        }
    }
}

#Preview {
    ContentView()
}
