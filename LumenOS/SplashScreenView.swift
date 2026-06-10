import SwiftUI

struct SplashScreenView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var size = 0.95
    @State private var glowOpacity = 0.0

    var body: some View {
        if isActive {
            ContentView()
                .environmentObject(themeManager)
        } else {
            ZStack {
                // 背景：使用主题背景色 + 主题色氛围光
                ZStack {
                    themeManager.selectedTheme.background.ignoresSafeArea()
                    RadialGradient(
                        gradient: Gradient(colors: [themeManager.selectedTheme.primary.opacity(0.08), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                }

                VStack(spacing: 30) {
                    // 图标区域
                    ZStack {
                        // 底层弥散辉光跟随主题
                        RoundedRectangle(cornerRadius: 28)
                            .fill(themeManager.selectedTheme.primary)
                            .frame(width: 100, height: 100)
                            .blur(radius: 40)
                            .opacity(glowOpacity * 0.3)

                        Image("splash_icon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear, themeManager.selectedTheme.primary.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                            .shadow(color: themeManager.selectedTheme.primary.opacity(0.15), radius: 25, x: 0, y: 15)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)

                    // 文字区域
                    VStack(spacing: 8) {
                        Text("LumenOS")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(8)

                        Text("ILLUMINATING YOUR WORLD")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(themeManager.selectedTheme.primary.opacity(0.6))
                            .tracking(3)
                    }
                    .opacity(opacity)
                    .offset(y: opacity == 1.0 ? 0 : 10)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    self.glowOpacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
