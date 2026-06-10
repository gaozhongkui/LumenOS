import SwiftUI

struct BarrageView: View {
    @StateObject private var manager = FlashlightManager.shared

    // Barrage Settings
    @State private var text: String = "LumenOS 极简弹幕"
    @State private var speed: Double = 5.0
    @State private var fontSize: CGFloat = 60
    @State private var selectedColor: Color = .yellow
    @State private var isRGB: Bool = true
    @State private var isLED: Bool = false
    @State private var bgType: BarrageBGType = .black
    @State private var isTorchSync: Bool = false

    // UI State
    @FocusState private var isInputFocused: Bool

    let colors: [Color] = [.white, .yellow, .orange, .red, .pink, .purple, .blue, .green]
    let presets = ["捞人", "打 Call", "生日快乐", " (｡♥‿♥｡) ", " ✺◟(∗❛ัᴗ❛ั∗)◞✺ ", "前方高能", "全军出击"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // 1. 实时预览框 (Live Preview)
                VStack(alignment: .leading, spacing: 12) {
                    Text("实时预览")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    ZStack {
                        // 手机外框模型效果
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(LinearGradient(colors: [Color(white: 0.3), Color(white: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6)
                            .background(Color.black)

                        // 预览核心内容
                        BarragePreviewContainer(
                            text: text,
                            speed: speed,
                            color: selectedColor,
                            isRGB: isRGB,
                            isLED: isLED,
                            bgType: bgType,
                            isTorchSync: isTorchSync
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // 模拟听筒/摄像头区域
                        Capsule()
                            .fill(Color(white: 0.1))
                            .frame(width: 60, height: 20)
                            .offset(x: -80)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // 2. 文本输入区域
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack(alignment: .trailing) {
                                    TextField("", text: $text, prompt: Text("输入弹幕内容...").foregroundColor(.gray))
                                        .padding(14)
                                        .background(Color(white: 0.12))
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
                                    Text("完成")
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
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
                                                .background(Color.yellow.opacity(0.15))
                                                .foregroundColor(.yellow)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }

                        // 3. 控制面板
                        VStack(spacing: 25) {
                            ControlSection(title: "滚动速度", icon: "speedometer") {
                                HStack {
                                    Image(systemName: "tortoise.fill").foregroundColor(.gray)
                                    Slider(value: $speed, in: 1...10)
                                        .accentColor(.yellow)
                                    Image(systemName: "hare.fill").foregroundColor(.gray)
                                }
                            }

                            ControlSection(title: "文字颜色 & 特效", icon: "paintbrush.fill") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        Button(action: { isRGB = true }) {
                                            Circle()
                                                .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                                                .frame(width: 34, height: 34)
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
                                ToggleCard(title: "LED 点阵", isOn: $isLED, icon: "grid")
                                ToggleCard(title: "闪光联动", isOn: $isTorchSync, icon: "flashlight.on.fill")
                            }

                            ControlSection(title: "动态背景", icon: "sparkles") {
                                HStack(spacing: 10) {
                                    ForEach([BarrageBGType.black, .hearts, .stars, .aurora], id: \.self) { type in
                                        Button(action: { bgType = type }) {
                                            Text(type.rawValue)
                                                .font(.system(size: 13, weight: .medium))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(bgType == type ? Color.yellow : Color(white: 0.15))
                                                .foregroundColor(bgType == type ? .black : .gray)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(white: 0.08))
                        .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .onTapGesture { isInputFocused = false }
    }
}

// MARK: - Barrage Engine

struct BarragePreviewContainer: View {
    let text: String
    let speed: Double
    let color: Color
    let isRGB: Bool
    let isLED: Bool
    let bgType: BarrageBGType
    let isTorchSync: Bool

    var body: some View {
        ZStack {
            BarrageBackgroundView(type: bgType)

            GeometryReader { geo in
                MarqueeEngine(text: text, speed: speed, color: color, isRGB: isRGB, isLED: isLED, isTorchSync: isTorchSync, containerSize: geo.size)
            }

            if isLED {
                LEDOverlayMask()
            }
        }
    }
}

struct MarqueeEngine: View {
    let text: String
    let speed: Double
    let color: Color
    let isRGB: Bool
    let isLED: Bool
    let isTorchSync: Bool
    let containerSize: CGSize

    @StateObject private var manager = FlashlightManager.shared

    var body: some View {
        TimelineView(.animation) { timelineContext in
            let time = timelineContext.date.timeIntervalSinceReferenceDate
            let width = textWidth(text)
            let duration = 15.0 / speed
            let totalDist = containerSize.width + width
            let progress = (time.truncatingRemainder(dividingBy: duration)) / duration
            let xOffset = containerSize.width - (progress * totalDist)

            Group {
                if isRGB {
                    Text(text)
                        .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red], startPoint: .leading, endPoint: .trailing))
                        .hueRotation(.degrees(time * 200))
                } else {
                    Text(text)
                        .foregroundColor(color)
                }
            }
            .font(.system(size: 80, weight: .black, design: .rounded))
            .fixedSize()
            .offset(x: xOffset, y: containerSize.height / 2 - 45)
            .onChange(of: timelineContext.date) { _ in
                if isTorchSync {
                    let strobe = Int(time * speed * 2) % 2 == 0
                    manager.toggle(isOn: strobe, level: 0.3)
                }
            }
        }
    }

    private func textWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 80, weight: .black)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
}

struct LEDOverlayMask: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 5
            let dotSize: CGFloat = 3
            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)), with: .color(.black.opacity(0.7)))
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
            case .hearts: FallingHeartsView()
            case .stars: TwinklingStarsView()
            case .aurora: AuroraWaveView()
            case .black: EmptyView()
            }
        }
    }
}

struct FallingHeartsView: View {
    var body: some View {
        TimelineView(.animation) { timelineContext in
            Canvas { gc, size in
                let time = timelineContext.date.timeIntervalSinceReferenceDate
                for i in 0..<12 {
                    let seed = Double(i * 345)
                    let x = (sin(time + seed) * 0.4 + 0.5) * size.width
                    let y = ((time * 0.5 + seed).truncatingRemainder(dividingBy: 1.0)) * size.height
                    gc.draw(Text("❤️").font(.system(size: 20)), at: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

struct TwinklingStarsView: View {
    var body: some View {
        TimelineView(.animation) { timelineContext in
            Canvas { gc, size in
                let time = timelineContext.date.timeIntervalSinceReferenceDate
                for i in 0..<40 {
                    let x = Double((i * 789) % Int(size.width))
                    let y = Double((i * 123) % Int(size.height))
                    let opacity = 0.3 + 0.7 * abs(sin(time + Double(i)))
                    gc.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)), with: .color(.white.opacity(opacity)))
                }
            }
        }
    }
}

struct AuroraWaveView: View {
    var body: some View {
        TimelineView(.animation) { timelineContext in
            LinearGradient(colors: [.blue.opacity(0.4), .green.opacity(0.4), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(timelineContext.date.timeIntervalSinceReferenceDate * 40))
                .ignoresSafeArea()
        }
    }
}

// MARK: - Helper Views

enum BarrageBGType: String {
    case black = "纯黑"
    case hearts = "浪漫爱心"
    case stars = "璀璨星空"
    case aurora = "幻彩极光"
}

struct ControlSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
            content
        }
    }
}

struct ToggleCard: View {
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
            .background(isOn ? Color.yellow : Color(white: 0.15))
            .foregroundColor(isOn ? .black : .white)
            .cornerRadius(16)
        }
    }
}

#Preview {
    BarrageView()
}
