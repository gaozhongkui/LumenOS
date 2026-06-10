import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var size = 0.95
    @State private var glowOpacity = 0.0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // 背景：中心微弱的径向渐变，营造氛围感
                ZStack {
                    Color.l_background.ignoresSafeArea()
                    RadialGradient(
                        gradient: Gradient(colors: [Color.l_gold.opacity(0.08), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                }

                VStack(spacing: 30) {
                    // 图标区域
                    ZStack {
                        // 底层核心发光 (弥散阴影)
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.l_gold)
                            .frame(width: 100, height: 100)
                            .blur(radius: 40)
                            .opacity(glowOpacity * 0.3)

                        Image("splash_icon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            // 极细的金属质感描边
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear, .l_gold.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            // 层次感阴影：深色底影 + 金色氛围影
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                            .shadow(color: Color.l_gold.opacity(0.15), radius: 25, x: 0, y: 15)
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
                            .foregroundColor(Color.l_gold.opacity(0.6))
                            .tracking(3)
                    }
                    .opacity(opacity)
                    .offset(y: opacity == 1.0 ? 0 : 10)
                }
            }
            .onAppear {
                // 入场动画：图标缩放、透明度以及呼吸灯般的辉光
                withAnimation(.easeOut(duration: 1.0)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    self.glowOpacity = 1.0
                }

                // 停留并切换
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
