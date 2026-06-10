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

            Text("弹幕界面")
                .tabItem {
                    Label("弹幕", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)

            Text("我的")
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.yellow)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
