import SwiftUI
import StoreKit

struct FlashlightView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var manager = FlashlightManager.shared
    @StateObject private var subManager = SubscriptionManager.shared

    @State private var isOn = false
    @State private var intensity: CGFloat = 0.6
    @State private var rotation: Double = 0
    @State private var selectedColor: Color = .l_gold
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            // Background
            themeManager.selectedTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 60)
                        .onChange(of: isOn) { newValue in
                            if newValue {
                                if subManager.canUseFlashlight() {
                                    subManager.recordFlashlightUsage()
                                    applyFlashlightChange(isOn: true)
                                } else {
                                    isOn = false
                                    showPaywall = true
                                }
                            } else {
                                applyFlashlightChange(isOn: false)
                            }
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

                // Center Power Button
                ZStack {
                    if isOn {
                        Circle()
                            .fill(RadialGradient(gradient: Gradient(colors: [selectedColor.opacity(0.4 * intensity), Color.clear]), center: .center, startRadius: 50, endRadius: 150))
                            .frame(width: 300, height: 300)
                            .transition(.opacity.animation(.easeInOut))
                    }

                    ForEach(0..<4) { i in
                        Circle()
                            .stroke(isOn ? selectedColor.opacity(0.2) : Color.white.opacity(0.05), lineWidth: 1)
                            .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                    }

                    Button(action: {
                        if !isOn {
                            if subManager.canUseFlashlight() {
                                subManager.recordFlashlightUsage()
                                isOn = true
                            } else {
                                showPaywall = true
                            }
                        } else {
                            isOn = false
                        }
                    }) {
                        PowerButtonUI(isOn: isOn, selectedColor: selectedColor)
                    }
                }
                .animation(.spring(), value: isOn)

                Spacer()

                // Bottom Panel
                HStack(alignment: .bottom) {
                    // 1. Intensity Bar
                    VStack(spacing: 5) {
                        Text("100%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)

                        IntensityBar(intensity: intensity, selectedColor: selectedColor)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let dragValue = 1.0 - (value.location.y / 170)
                                        intensity = max(0.01, min(dragValue, 1.0))
                                        if isOn { manager.setIntensity(Float(intensity)) }
                                        manager.triggerSelectionFeedback()
                                    }
                            )

                        Text("0%")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 2. Mode Knob
                    VStack(spacing: 20) {
                        ZStack {
                            // Dashed guide circle
                            Circle()
                                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
                                .frame(width: 140, height: 140)

                            // Mode Items (Dots and Labels)
                            ModeItem(text: NSLocalizedString("mode_sos", comment: ""), angle: 0, currentRotation: rotation)
                            ModeItem(icon: "rays", angle: -45, currentRotation: rotation)
                            ModeItem(icon: "antenna.radiowaves.left.and.right", angle: -90, currentRotation: rotation)
                            ModeItem(icon: "speaker.slash.fill", angle: -135, currentRotation: rotation)
                            ModeItem(text: NSLocalizedString("mode_party", comment: ""), angle: 45, currentRotation: rotation)
                            ModeItem(text: NSLocalizedString("mode_setc", comment: ""), angle: 90, currentRotation: rotation)

                            KnobUI(rotation: rotation, selectedColor: selectedColor)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let vector = CGVector(dx: value.location.x - 55, dy: value.location.y - 55)
                                            rotation = atan2(vector.dy, vector.dx) * 180 / .pi + 90
                                            updateMode()
                                            manager.triggerSelectionFeedback()
                                        }
                                )

                            // Knob Indicator
                            RoundedRectangle(cornerRadius: 1)
                                .fill(selectedColor)
                                .frame(width: 3, height: 12)
                                .offset(y: -42)
                                .rotationEffect(.degrees(rotation))
                        }
                        .frame(width: 180, height: 180)

                        Text(NSLocalizedString("label_color", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 3. Color Picker
                    VStack {
                        ColorPickerUI(selectedColor: $selectedColor)
                        Spacer().frame(height: 25)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .onChange(of: themeManager.selectedTheme) { newTheme in
            // 当用户更换皮肤时，如果灯没开，自动将选色设为皮肤主色
            if !isOn {
                selectedColor = newTheme.primary
            }
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
        }
    }

    private func updateMode() {
        let r = rotation.truncatingRemainder(dividingBy: 360)
        let normalized = r < -180 ? r + 360 : (r > 180 ? r - 360 : r)

        if abs(normalized) < 20 { manager.currentMode = .sos }
        else if normalized > -60 && normalized < -30 { manager.currentMode = .strobe }
        else { manager.currentMode = .standard }

        if isOn { manager.toggle(isOn: true, level: Float(intensity)) }
    }

    private func applyFlashlightChange(isOn: Bool) {
        manager.toggle(isOn: isOn, level: Float(intensity))
        manager.triggerHapticFeedback()
    }
}

// MARK: - UI Components (Updated with Theme Support)

struct PowerButtonUI: View {
    let isOn: Bool
    let selectedColor: Color
    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.1)]), startPoint: .top, endPoint: .bottom))
                .frame(width: 120, height: 120).shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
            Circle().stroke(isOn ? selectedColor.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 100, height: 100)
            Image(systemName: "power")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(isOn ? selectedColor : .gray)
                .shadow(color: isOn ? selectedColor.opacity(0.8) : .clear, radius: 10)
        }
    }
}

struct IntensityBar: View {
    let intensity: CGFloat
    let selectedColor: Color
    var body: some View {
        VStack(spacing: 3) {
            ForEach((0..<18).reversed(), id: \.self) { i in
                Rectangle()
                    .fill(CGFloat(i) / 18.0 < intensity ? LinearGradient(colors: [selectedColor, selectedColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color(white: 0.15), Color(white: 0.1)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 35, height: 6).cornerRadius(1)
            }
        }
        .padding(5).background(Color.black.opacity(0.3)).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct KnobUI: View {
    let rotation: Double
    let selectedColor: Color
    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [Color(white: 0.2), Color(white: 0.1)], startPoint: .top, endPoint: .bottom))
                .frame(width: 110, height: 110).shadow(radius: 10)
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

struct ModeItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    var text: String? = nil
    var icon: String? = nil
    var angle: Double
    var currentRotation: Double

    var isSelected: Bool {
        let r = currentRotation.truncatingRemainder(dividingBy: 360)
        let normalized = r < -180 ? r + 360 : (r > 180 ? r - 360 : r)
        return abs(normalized - angle) < 15
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? themeManager.selectedTheme.primary : Color.white.opacity(0.4))
                .frame(width: 4, height: 4)
                .offset(y: -70)
                .rotationEffect(.degrees(angle))

            Group {
                if let text = text {
                    Text(text)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            .foregroundColor(isSelected ? themeManager.selectedTheme.primary : .white.opacity(0.6))
            .rotationEffect(.degrees(-angle))
            .offset(y: -85)
            .rotationEffect(.degrees(angle))
        }
    }
}

struct ColorPickerUI: View {
    @Binding var selectedColor: Color
    var body: some View {
        ZStack {
            ColorPicker("", selection: $selectedColor).labelsHidden().scaleEffect(3).frame(width: 44, height: 44).mask(Circle()).zIndex(1)
            Circle().fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color.white, lineWidth: 2).frame(width: 12, height: 12).offset(x: 12))
                .shadow(radius: 5).allowsHitTesting(false).zIndex(2)
        }
    }
}

struct CustomToggleStyle: ToggleStyle {
    @EnvironmentObject var themeManager: ThemeManager
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16).fill(themeManager.selectedTheme.surface).frame(width: 50, height: 28)
                .overlay(Circle().fill(LinearGradient(colors: [themeManager.selectedTheme.primary, themeManager.selectedTheme.secondary], startPoint: .top, endPoint: .bottom)).padding(3).offset(x: configuration.isOn ? 11 : -11))
        }
    }
}

struct SubscriptionPaywallView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var isPurchasing = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("💎").font(.system(size: 80))
            VStack(spacing: 15) {
                Text(NSLocalizedString("paywall_title_buyout", comment: ""))
                    .font(.title2.bold())
                Text(NSLocalizedString("paywall_subtitle_buyout", comment: ""))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            VStack(spacing: 15) {
                Button(action: {
                    Task {
                        isPurchasing = true
                        do {
                            try await subManager.purchase()
                            if subManager.isSubscribed { dismiss() }
                        } catch {
                            print("Purchase failed: \(error)")
                        }
                        isPurchasing = false
                    }
                }) {
                    HStack {
                        if isPurchasing { ProgressView().tint(.black).padding(.trailing, 5) }
                        Text(subManager.products.first?.displayPrice ?? NSLocalizedString("btn_unlock_price", comment: ""))
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.selectedTheme.primary)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .disabled(isPurchasing)

                Button(NSLocalizedString("btn_restore_purchase", comment: "")) {
                    Task { await subManager.restore() }
                }
                .foregroundColor(themeManager.selectedTheme.primary)

                Button(NSLocalizedString("btn_not_now", comment: "")) {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)

            Spacer()

            // Legal Links (App Store Requirement)
            HStack(spacing: 25) {
                Link(NSLocalizedString("privacy_policy", comment: ""), destination: URL(string: "https://your-privacy-policy-link.com")!)
                Link(NSLocalizedString("terms_of_service", comment: ""), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
        .background(themeManager.selectedTheme.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
