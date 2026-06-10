import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8

    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.12)
                    .ignoresSafeArea()

                VStack {
                    VStack(spacing: 20) {
                        ZStack {
                            // 外围光晕
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)

                            Image(systemName: "flashlight.on.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                        }

                        Text("LumenOS")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(5)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
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
