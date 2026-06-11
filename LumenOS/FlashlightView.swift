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
    @State private var batteryLevel: Float = -1
    @State private var batteryState: UIDevice.BatteryState = .unknown
    @State private var thermalState: ProcessInfo.ThermalState = .nominal

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
                                    manager.toggle(isOn: true, level: Float(intensity))
                                } else {
                                    isOn = false
                                    showPaywall = true
                                }
                            } else {
                                manager.toggle(isOn: false)
                            }
                            manager.triggerHapticFeedback()
                        }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: thermalIconName)
                            .foregroundColor(thermalColor)
                        Image(systemName: batteryIconName)
                            .foregroundColor(batteryColor)
                        if batteryState == .charging || batteryState == .full {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
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
                            ModeItem(text: NSLocalizedString("mode_strobe", comment: ""), angle: -45, currentRotation: rotation)
                            ModeItem(text: NSLocalizedString("mode_pulse", comment: ""), angle: -90, currentRotation: rotation)
                            ModeItem(text: NSLocalizedString("mode_silent", comment: ""), angle: -135, currentRotation: rotation)
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

                        Text(manager.currentMode.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedColor)
                            .animation(.easeInOut(duration: 0.2), value: manager.currentMode)
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
            if !isOn {
                selectedColor = newTheme.primary
            }
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            batteryLevel = UIDevice.current.batteryLevel
            batteryState = UIDevice.current.batteryState
            thermalState = ProcessInfo.processInfo.thermalState
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)) { _ in
            batteryLevel = UIDevice.current.batteryLevel
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)) { _ in
            batteryState = UIDevice.current.batteryState
        }
        .onReceive(NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)) { _ in
            thermalState = ProcessInfo.processInfo.thermalState
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
        }
    }

    private var batteryIconName: String {
        guard batteryLevel >= 0 else { return "battery.100" }  // 模拟器/未知状态
        if batteryState == .charging || batteryState == .full {
            return "battery.100.bolt"
        }
        switch batteryLevel {
        case 0.75...: return "battery.100"
        case 0.50...: return "battery.75"
        case 0.25...: return "battery.50"
        case 0.10...: return "battery.25"
        default:      return "battery.0"
        }
    }

    private var batteryColor: Color {
        guard batteryLevel >= 0 else { return .white.opacity(0.6) }  // 模拟器/未知状态
        if batteryState == .charging || batteryState == .full { return .green }
        if batteryLevel <= 0.10 { return .red }
        if batteryLevel <= 0.25 { return .yellow }
        return .white
    }

    private var thermalIconName: String {
        switch thermalState {
        case .serious:  return "thermometer.high"
        case .critical: return "thermometer.sun.fill"
        default:        return "thermometer.medium"
        }
    }

    private var thermalColor: Color {
        switch thermalState {
        case .nominal:  return .white.opacity(0.6)
        case .fair:     return .yellow
        case .serious:  return .orange
        case .critical: return .red
        @unknown default: return .white.opacity(0.6)
        }
    }

    private func updateMode() {
        let r = rotation.truncatingRemainder(dividingBy: 360)
        let normalized = r < -180 ? r + 360 : (r > 180 ? r - 360 : r)

        let newMode: FlashlightManager.FlashlightMode?
        if abs(normalized - 0) < 15 {
            newMode = .sos
        } else if abs(normalized - (-45)) < 15 {
            newMode = .strobe
        } else if abs(normalized - (-90)) < 15 {
            newMode = .pulse
        } else if abs(normalized - (-135)) < 15 {
            newMode = .silent
        } else if abs(normalized - 45) < 15 {
            newMode = .party
        } else if abs(normalized - 90) < 15 {
            newMode = .standard
        } else {
            newMode = nil  // between positions: keep current mode
        }

        guard let newMode, newMode != manager.currentMode else { return }
        manager.currentMode = newMode
        if isOn {
            manager.restartCurrentMode()
        }
    }
}

// MARK: - UI Components

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
    @State private var webURL: URL? = nil
    @State private var purchaseErrorMessage: String? = nil

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
                            purchaseErrorMessage = error.localizedDescription
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

            // Legal Links
            HStack(spacing: 25) {
                Button(NSLocalizedString("privacy_policy", comment: "")) {
                    webURL = URL(string: "https://sites.google.com/view/lumenos-privacy-policy")
                }
                Button(NSLocalizedString("terms_of_service", comment: "")) {
                    webURL = URL(string: "https://sites.google.com/view/lumenos-terms-of-service")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
        .background(themeManager.selectedTheme.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(item: $webURL) { url in
            WebBrowserView(title: url.host ?? "", url: url)
        }
        .alert(NSLocalizedString("alert_purchase_failed_title", comment: ""), isPresented: Binding(
            get: { purchaseErrorMessage != nil },
            set: { if !$0 { purchaseErrorMessage = nil } }
        )) {
            Button(NSLocalizedString("btn_ok", comment: ""), role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage ?? "")
        }
    }
}
