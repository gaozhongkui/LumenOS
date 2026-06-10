import SwiftUI

struct FlashlightView: View {
    @StateObject private var manager = FlashlightManager.shared
    @State private var isOn = false
    @State private var intensity: CGFloat = 0.6
    @State private var rotation: Double = 0
    @State private var selectedColor: Color = .yellow

    var body: some View {
        ZStack {
            // 背景深蓝黑色
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部状态栏
                HStack {
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 60)
                        .onChange(of: isOn) { newValue in
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
                    if isOn {
                        Circle()
                            .fill(RadialGradient(gradient: Gradient(colors: [selectedColor.opacity(0.4 * intensity), Color.clear]), center: .center, startRadius: 50, endRadius: 150))
                            .frame(width: 300, height: 300)
                            .transition(.opacity.animation(.easeInOut))
                    }

                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(isOn ? selectedColor.opacity(0.2) : Color.white.opacity(0.05), lineWidth: 1)
                            .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                    }

                    Button(action: { isOn.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)

                            Circle()
                                .stroke(isOn ? selectedColor.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)

                            Image(systemName: "power")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(isOn ? selectedColor : .gray)
                        }
                    }
                }
                .animation(.spring(), value: isOn)

                Spacer()

                // 底部控制面板
                HStack(alignment: .bottom) {
                    // 1. 亮度调节条
                    VStack(spacing: 5) {
                        Text("100%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)

                        VStack(spacing: 3) {
                            ForEach((0..<18).reversed(), id: \.self) { i in
                                Rectangle()
                                    .fill(CGFloat(i) / 18.0 < intensity ?
                                          LinearGradient(gradient: Gradient(colors: [selectedColor, selectedColor.opacity(0.7)]), startPoint: .leading, endPoint: .trailing) :
                                          LinearGradient(gradient: Gradient(colors: [Color(white: 0.15), Color(white: 0.1)]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: 35, height: 6)
                                    .cornerRadius(1)
                            }
                        }
                        .padding(5)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let barHeight: CGFloat = 170
                                    let dragValue = 1.0 - (value.location.y / barHeight)
                                    let newIntensity = max(0.01, min(dragValue, 1.0))
                                    if abs(newIntensity - intensity) > 0.02 {
                                        intensity = newIntensity
                                        if isOn { manager.setIntensity(Float(intensity)) }
                                        manager.triggerSelectionFeedback()
                                    }
                                }
                        )

                        Text("0%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 2. 中间旋钮
                    VStack(spacing: 15) {
                        ZStack {
                            // 模式标签位置
                            ModeLabel(text: "SOS", angle: 0)
                            ModeLabel(icon: "rays", angle: -45)
                            ModeLabel(icon: "antenna.radiowaves.left.and.right", angle: -90)
                            ModeLabel(icon: "speaker.slash.fill", angle: -135)

                            ModeText(text: "Party Mode", angle: 45)
                            ModeText(text: "Setc", angle: 90)

                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 110, height: 110)
                                .shadow(radius: 10)
                                .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let vector = CGVector(dx: value.location.x - 55, dy: value.location.y - 55)
                                            let angle = atan2(vector.dy, vector.dx)
                                            rotation = angle * 180 / .pi + 90
                                            manager.triggerSelectionFeedback()
                                        }
                                )

                            Rectangle()
                                .fill(selectedColor)
                                .frame(width: 2, height: 12)
                                .offset(y: -42)
                                .rotationEffect(.degrees(rotation))
                        }
                        .frame(width: 160, height: 160)

                        Text("Color")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 3. 颜色选择器
                    VStack {
                        ZStack {
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .scaleEffect(3)
                                .frame(width: 44, height: 44)
                                .mask(Circle())
                                .zIndex(1)

                            Circle()
                                .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 12, height: 12)
                                        .offset(x: 10, y: 0)
                                )
                                .shadow(radius: 5)
                                .allowsHitTesting(false)
                                .zIndex(2)
                        }
                        Spacer().frame(height: 25)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
    }
}

struct ModeLabel: View {
    var text: String? = nil
    var icon: String? = nil
    var angle: Double
    var body: some View {
        Group {
            if let text = text { Text(text) }
            else if let icon = icon { Image(systemName: icon) }
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(.white.opacity(0.6))
        .offset(y: -80)
        .rotationEffect(.degrees(angle))
    }
}

struct ModeText: View {
    var text: String
    var angle: Double
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white.opacity(0.6))
            .offset(x: 75)
            .rotationEffect(.degrees(angle - 90))
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
                .frame(width: 50, height: 28)
                .overlay(
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom))
                        .padding(3)
                        .offset(x: configuration.isOn ? 11 : -11)
                )
        }
    }
}

#Preview {
    FlashlightView()
}
