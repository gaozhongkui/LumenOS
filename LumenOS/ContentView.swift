//
//  ContentView.swift
//  LumenOS
//

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

// 简单的“我的”页面
struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Lumen 用户")
                                .font(.headline)
                            Text("ID: 12345678")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("常用功能")) {
                    Label("设置", systemImage: "gear")
                    Label("意见反馈", systemImage: "envelope")
                    Label("关于我们", systemImage: "info.circle")
                }
            }
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ContentView()
}
