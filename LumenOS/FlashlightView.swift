import SwiftUI

struct FlashlightView: View {
    @State private var isOn = false
    @State private var intensity: CGFloat = 0.6
    @State private var rotation: Double = 0
    @State private var selectedMode: String = "SOS"

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 60)
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

                // Central Power Button
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.clear]), center: .center, startRadius: 50, endRadius: 150))
                        .frame(width: 300, height: 300)

                    // Ripple rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                            .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                    }

                    // Main Button
                    Button(action: { isOn.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)

                            Circle()
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                                .frame(width: 100, height: 100)

                            Image(systemName: "power")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(isOn ? .yellow : .gray)
                        }
                    }
                }

                Spacer()

                // Bottom Controls
                HStack(alignment: .bottom, spacing: 30) {
                    // Intensity Vertical Bar
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

                        Text("0%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    // Rotary Dial
                    VStack {
                        ZStack {
                            // Mode Icons/Labels around the dial
                            ModeLabel(text: "SOS", angle: -30)
                            ModeLabel(icon: "rays", angle: -70)
                            ModeLabel(icon: "antenna.radiowaves.left.and.right", angle: -110)
                            ModeLabel(icon: "speaker.slash.fill", angle: -150)
                            ModeLabel(icon: "flashlight.on.fill", angle: 10)
                            ModeText(text: "Party Mode", angle: 40)
                            ModeText(text: "Setc", angle: 70)

                            // The Knob
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 120, height: 120)
                                .shadow(radius: 5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            // Indicator line on knob
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

                    // Color Picker Button
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
