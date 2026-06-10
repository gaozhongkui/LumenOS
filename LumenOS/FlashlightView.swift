import SwiftUI

struct FlashlightView: View {
    // 引入手电筒管理器
    @StateObject private var manager = FlashlightManager.shared

    @State private var isOn = false
    @State private var intensity: CGFloat = 0.6
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // 背景
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // 顶部状态栏
                HStack {
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 60)
                        .onChange(of: isOn) { newValue in
                            // 同步硬件开关
                            manager.toggle(isOn: newValue, level: Float(intensity))
                            manager.triggerHapticFeedback()
                        }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "thermometer.medium")
                        Text("27°")
                        Image(systemName: "battery.75")
                            .foregroundColor(.green)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                }
                .padding(.top, 10)

                Spacer()

                // 中央电源大按钮
                ZStack {
                    // 开启时的光晕效果 (随亮度变化)
                    if isOn {
                        Circle()
                            .fill(RadialGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.4 * intensity), Color.clear]), center: .center, startRadius: 50, endRadius: 150))
                            .frame(width: 300, height: 300)
                            .transition(.opacity.animation(.easeInOut))
                    }

                    // 装饰性波纹圆环
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(isOn ? Color.yellow.opacity(0.2) : Color.white.opacity(0.05), lineWidth: 1)
                            .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                    }

                    // 主电源按钮
                    Button(action: {
                        isOn.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)

                            Circle()
                                .stroke(isOn ? Color.yellow.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)

                            Image(systemName: "power")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(isOn ? .yellow : .gray)
                        }
                    }
                }
                .animation(.spring(), value: isOn)

                Spacer()

                // 底部控制面板
                HStack(alignment: .bottom, spacing: 30) {
                    // 亮度调节条 (左侧)
                    VStack(spacing: 5) {
                        Text("100%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)

                        VStack(spacing: 2) {
                            ForEach((0..<20).reversed(), id: \.self) { i in
                                Rectangle()
                                    .fill(CGFloat(i) / 20.0 < intensity ?
                                          LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing) :
                                          LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: 40, height: 6)
                                    .cornerRadius(2)
                            }
                        }
                        .padding(4)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let barHeight: CGFloat = 160 // 容器大概高度
                                    let dragValue = 1.0 - (value.location.y / barHeight)
                                    let newIntensity = max(0.01, min(dragValue, 1.0))

                                    if abs(newIntensity - intensity) > 0.02 {
                                        intensity = newIntensity
                                        if isOn {
                                            manager.setIntensity(Float(intensity))
                                        }
                                        manager.triggerSelectionFeedback()
                                    }
                                }
                        )

                        Text("0%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    // 模式切换旋钮 (中间)
                    VStack {
                        ZStack {
                            // 环绕模式标签
                            ModeLabel(text: "SOS", angle: -30)
                            ModeLabel(icon: "rays", angle: -70)
                            ModeLabel(icon: "antenna.radiowaves.left.and.right", angle: -110)
                            ModeLabel(icon: "speaker.slash.fill", angle: -150)
                            ModeLabel(icon: "flashlight.on.fill", angle: 10)
                            ModeText(text: "Party Mode", angle: 40)
                            ModeText(text: "Setc", angle: 70)

                            // 旋钮主体与旋转手势
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(radius: 5)
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let vector = CGVector(dx: value.location.x - 60, dy: value.location.y - 60)
                                            let angle = atan2(vector.dy, vector.dx)
                                            let degrees = angle * 180 / .pi
                                            rotation = degrees + 90 // 修正起始角度
                                            manager.triggerSelectionFeedback()
                                        }
                                )

                            // 旋钮指示器
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 2, height: 15)
                                .offset(y: -45)
                                .rotationEffect(.degrees(rotation))
                        }
                        .frame(width: 180, height: 180)

                        Text("Color")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    // 颜色选择预览 (右侧)
                    VStack {
                        Circle()
                            .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 15, height: 15)
                                    .offset(x: 10, y: 0)
                            )
                            .shadow(radius: 5)

                        Spacer().frame(height: 20)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// 辅助组件保持不变
struct ModeLabel: View {
    var text: String? = nil
    var icon: String? = nil
    var angle: Double

    var body: some View {
        Group {
            if let text = text {
                Text(text)
            } else if let icon = icon {
                Image(systemName: icon)
            }
        }
        .font(.system(size: 10))
        .foregroundColor(.gray)
        .offset(y: -85)
        .rotationEffect(.degrees(angle))
    }
}

struct ModeText: View {
    var text: String
    var angle: Double

    var body: some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .offset(x: 80)
            .rotationEffect(.degrees(angle))
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.2))
                .frame(width: 50, height: 26)
                .overlay(
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                        .padding(3)
                        .offset(x: configuration.isOn ? 12 : -12)
                )
        }
    }
}

#Preview {
    FlashlightView()
}
