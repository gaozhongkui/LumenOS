import SwiftUI

struct BarrageView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var manager = FlashlightManager.shared
    @StateObject private var subManager = SubscriptionManager.shared

    // Barrage Settings
    @State private var text: String = NSLocalizedString("default_barrage_text", comment: "")
    @State private var speed: Double = 5.0
    @State private var selectedColor: Color = .l_gold
    @State private var isRGB: Bool = true
    @State private var isLED: Bool = false
    @State private var bgType: BarrageBGType = .black
    @State private var isTorchSync: Bool = false

    // UI State
    @FocusState private var isInputFocused: Bool
    @State private var showFullScreen: Bool = false
    @State private var showPaywall = false

    var colors: [Color] {
        [.white, themeManager.selectedTheme.primary, themeManager.selectedTheme.secondary, .red, .pink, .purple, .blue, .green]
    }

    let presets = [
        NSLocalizedString("preset_pickup", comment: ""),
        NSLocalizedString("preset_cheer", comment: ""),
        NSLocalizedString("preset_birthday", comment: ""),
        " (｡♥‿♥｡) ",
        " ✺◟(∗❛ัᴗ❛ั∗)◞✺ ",
        NSLocalizedString("preset_high_energy", comment: ""),
        NSLocalizedString("preset_attack", comment: "")
    ]

    var body: some View {
        ZStack {
            themeManager.selectedTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. Live Preview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("label_live_preview", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            if subManager.canUseBarrage() {
                                subManager.recordBarrageUsage()
                                showFullScreen = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                Text(NSLocalizedString("btn_full_screen", comment: ""))
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(themeManager.selectedTheme.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                            .background(Color.black)

                        BarrageEngineView(
                            text: text,
                            speed: speed,
                            color: selectedColor,
                            isRGB: isRGB,
                            isLED: isLED,
                            bgType: bgType,
                            isTorchSync: isTorchSync,
                            isFullScreen: false
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        Capsule()
                            .fill(Color(white: 0.1))
                            .frame(width: 60, height: 18)
                            .offset(y: -85)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // 2. Text Input
                        VStack(spacing: 12) {
                            Spacer().frame(height: 1)
                            HStack(spacing: 12) {
                                ZStack(alignment: .trailing) {
                                    TextField("", text: $text, prompt: Text(NSLocalizedString("placeholder_input_barrage", comment: "")).foregroundColor(.gray))
                                        .padding(14)
                                        .background(themeManager.selectedTheme.surface)
                                        .cornerRadius(12)
                                        .foregroundColor(.white)
                                        .focused($isInputFocused)

                                    if !text.isEmpty {
                                        Button(action: { text = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 10)
                                        }
                                    }
                                }

                                Button(action: { isInputFocused = false }) {
                                    Text(NSLocalizedString("btn_done", comment: ""))
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.selectedTheme.primary)
                                }
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(presets, id: \.self) { preset in
                                        Button(action: { text = preset }) {
                                            Text(preset)
                                                .font(.system(size: 13))
                                                .padding(.horizontal, 15)
                                                .padding(.vertical, 8)
                                                .background(themeManager.selectedTheme.primary.opacity(0.15))
                                                .foregroundColor(themeManager.selectedTheme.primary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }

                        // 3. Control Panel
                        VStack(spacing: 25) {
                            // Speed Section
                            VStack(alignment: .leading, spacing: 12) {
                                Label(NSLocalizedString("label_scroll_speed", comment: ""), systemImage: "speedometer")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                HStack {
                                    Image(systemName: "tortoise.fill").foregroundColor(.gray)
                                    Slider(value: $speed, in: 1...10)
                                        .accentColor(themeManager.selectedTheme.primary)
                                    Image(systemName: "hare.fill").foregroundColor(.gray)
                                }
                            }

                            // Color Effect Section
                            VStack(alignment: .leading, spacing: 12) {
                                Label(NSLocalizedString("label_color_effect", comment: ""), systemImage: "paintbrush.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        Button(action: { isRGB = true }) {
                                            Circle()
                                                .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                                                .frame(width: 36, height: 34)
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: isRGB ? 3 : 0)
                                                )
                                        }

                                        ForEach(colors, id: \.self) { color in
                                            Circle()
                                                .fill(color)
                                                .frame(width: 34, height: 34)
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: selectedColor == color && !isRGB ? 3 : 0)
                                                )
                                                .onTapGesture {
                                                    selectedColor = color
                                                    isRGB = false
                                                }
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }

                            HStack(spacing: 15) {
                                ToggleCard(title: NSLocalizedString("label_led_matrix", comment: ""), isOn: $isLED, icon: "grid")
                                ToggleCard(title: NSLocalizedString("label_torch_sync", comment: ""), isOn: $isTorchSync, icon: "flashlight.on.fill")
                            }

                            // Dynamic Background Section
                            VStack(alignment: .leading, spacing: 12) {
                                Label(NSLocalizedString("label_dynamic_bg", comment: ""), systemImage: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                HStack(spacing: 10) {
                                    ForEach(BarrageBGType.allCases) { type in
                                        Button(action: { bgType = type }) {
                                            Text(NSLocalizedString("bg_type_" + type.rawValue, comment: ""))
                                                .font(.system(size: 13, weight: .medium))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(bgType == type ? themeManager.selectedTheme.primary : themeManager.selectedTheme.surface)
                                                .foregroundColor(bgType == type ? .black : .gray)
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(themeManager.selectedTheme.surface.opacity(0.5))
                        .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
        }
        .onChange(of: themeManager.selectedTheme) { newTheme in
            selectedColor = newTheme.primary
        }
        .onTapGesture { isInputFocused = false }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenBarrageView(
                text: text,
                speed: speed,
                color: selectedColor,
                isRGB: isRGB,
                isLED: isLED,
                bgType: bgType,
                isTorchSync: isTorchSync
            )
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
        }
    }
}

// MARK: - Full Screen View

struct FullScreenBarrageView: View {
    @Environment(\.dismiss) var dismiss
    let text: String
    let speed: Double
    let color: Color
    let isRGB: Bool
    let isLED: Bool
    let bgType: BarrageBGType
    let isTorchSync: Bool

    var body: some View {
        ZStack {
            BarrageEngineView(
                text: text,
                speed: speed,
                color: color,
                isRGB: isRGB,
                isLED: isLED,
                bgType: bgType,
                isTorchSync: isTorchSync,
                isFullScreen: true
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(12)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            if isTorchSync {
                FlashlightManager.shared.toggle(isOn: false)
            }
        }
        .statusBar(hidden: true)
    }
}

// MARK: - Barrage Engine

struct BarrageEngineView: View {
    let text: String
    let speed: Double
    let color: Color
    let isRGB: Bool
    let isLED: Bool
    let bgType: BarrageBGType
    let isTorchSync: Bool
    let isFullScreen: Bool

    var body: some View {
        ZStack {
            BarrageBackgroundView(type: bgType)

            GeometryReader { geo in
                MarqueeCore(
                    text: text,
                    speed: speed,
                    color: color,
                    isRGB: isRGB,
                    isLED: isLED,
                    isTorchSync: isTorchSync,
                    containerSize: geo.size,
                    isFullScreen: isFullScreen
                )
            }

            if isLED {
                LEDOverlayLayer()
            }
        }
    }
}

struct MarqueeCore: View {
    let text: String
    let speed: Double
    let color: Color
    let isRGB: Bool
    let isLED: Bool
    let isTorchSync: Bool
    let containerSize: CGSize
    let isFullScreen: Bool

    @StateObject private var manager = FlashlightManager.shared

    var body: some View {
        TimelineView(.animation) { (timelineContext: TimelineViewDefaultContext) in
            let time = timelineContext.date.timeIntervalSinceReferenceDate
            let baseFontSize: CGFloat = isFullScreen ? 200 : 80
            let width = textWidth(text, size: baseFontSize)
            let duration = 15.0 / speed
            let totalDist = containerSize.width + width
            let progress = (time.truncatingRemainder(dividingBy: duration)) / duration
            let xOffset = containerSize.width - (progress * totalDist)

            ZStack {
                if isRGB {
                    Text(text)
                        .font(.system(size: baseFontSize, weight: .black, design: .rounded))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], startPoint: .leading, endPoint: .trailing)
                                .hueRotation(.degrees(time * 200))
                                .mask(
                                    Text(text)
                                        .font(.system(size: baseFontSize, weight: .black, design: .rounded))
                                )
                        )
                } else {
                    Text(text)
                        .font(.system(size: baseFontSize, weight: .black, design: .rounded))
                        .foregroundColor(color)
                }
            }
            .fixedSize()
            .offset(x: xOffset, y: (containerSize.height - baseFontSize) / 2)
            .onChange(of: timelineContext.date) { _ in
                if isTorchSync {
                    let strobe = Int(time * speed * 2) % 2 == 0
                    manager.toggle(isOn: strobe)
                }
            }
        }
    }

    private func textWidth(_ text: String, size: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size, weight: .black)
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)
        return textSize.width
    }
}

struct LEDOverlayLayer: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 6
            let dotSize: CGFloat = 3
            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)), with: .color(.black.opacity(0.8)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Backgrounds

struct BarrageBackgroundView: View {
    let type: BarrageBGType

    var body: some View {
        ZStack {
            Color.black
            switch type {
            case .hearts: FallingHeartsAnimation()
            case .stars: TwinklingStarsAnimation()
            case .aurora: AuroraGradientAnimation()
            case .black: Color.black
            }
        }
    }
}

struct FallingHeartsAnimation: View {
    var body: some View {
        TimelineView(.animation) { (timelineContext: TimelineViewDefaultContext) in
            let time = timelineContext.date.timeIntervalSinceReferenceDate
            Canvas { gc, size in
                for i in 0..<15 {
                    let seed = Double(i * 345)
                    let x = (sin(time + seed) * 0.4 + 0.5) * size.width
                    let y = ((time * 0.4 + seed).truncatingRemainder(dividingBy: 1.0)) * size.height
                    gc.draw(Text("❤️").font(.system(size: 24)), at: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

struct TwinklingStarsAnimation: View {
    var body: some View {
        TimelineView(.animation) { (timelineContext: TimelineViewDefaultContext) in
            let time = timelineContext.date.timeIntervalSinceReferenceDate
            Canvas { gc, size in
                for i in 0..<50 {
                    let x = Double((i * 789) % Int(size.width))
                    let y = Double((i * 123) % Int(size.height))
                    let opacity = 0.2 + 0.8 * abs(sin(time + Double(i)))
                    gc.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(.white.opacity(opacity)))
                }
            }
        }
    }
}

struct AuroraGradientAnimation: View {
    var body: some View {
        TimelineView(.animation) { (timelineContext: TimelineViewDefaultContext) in
            LinearGradient(colors: [.blue.opacity(0.4), .green.opacity(0.4), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(timelineContext.date.timeIntervalSinceReferenceDate * 40))
        }
    }
}

// MARK: - Helper Components

enum BarrageBGType: String, CaseIterable, Identifiable {
    case black, hearts, stars, aurora
    var id: String { self.rawValue }
}

struct ToggleCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var isOn: Bool
    let icon: String

    var body: some View {
        Button(action: { isOn.toggle() }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isOn ? themeManager.selectedTheme.primary : themeManager.selectedTheme.surface)
            .foregroundColor(isOn ? .black : .white)
            .cornerRadius(16)
        }
    }
}
