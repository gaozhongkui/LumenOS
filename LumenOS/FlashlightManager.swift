import AVFoundation
import UIKit
import SwiftUI
import Combine

final class FlashlightManager: ObservableObject {
    static let shared = FlashlightManager()

    private var device: AVCaptureDevice?
    private var strobeTimer: Timer?

    @Published var currentMode: FlashlightMode = .standard
    @Published var intensity: Float = 0.6

    init() {
        self.device = AVCaptureDevice.default(for: .video)
    }

    enum FlashlightMode {
        case standard, sos, strobe
    }

    /// Toggle flashlight switch with full logic (stops timers)
    func toggle(isOn: Bool, level: Float = 1.0) {
        self.intensity = level
        stopStrobe()

        guard let device = device, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isOn {
                switch currentMode {
                case .standard:
                    try device.setTorchModeOn(level: max(0.001, min(intensity, 1.0)))
                case .sos:
                    device.unlockForConfiguration()
                    startSOS()
                    return
                case .strobe:
                    device.unlockForConfiguration()
                    startStrobe()
                    return
                }
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Flashlight configuration failed: \(error)")
        }
    }

    /// Lightweight torch control for sync features
    func setTorchSync(isOn: Bool, level: Float = 0.3) {
        setTorchInternal(isOn: isOn, level: level)
    }

    /// Adjust intensity immediately
    func setIntensity(_ level: Float) {
        self.intensity = level
        guard let device = device, device.hasTorch, device.torchMode == .on else { return }

        if currentMode == .standard {
            setTorchInternal(isOn: true, level: level)
        }
    }

    // MARK: - Strobe & SOS Logic

    private func startStrobe() {
        var flashOn = false
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            flashOn.toggle()
            self.setTorchInternal(isOn: flashOn)
        }
    }

    private func startSOS() {
        let sosPattern: [TimeInterval] = [0.2, 0.2, 0.2, 0.2, 0.2, 0.6, 0.6, 0.2, 0.6, 0.2, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 1.0]
        var index = 0
        strobeTimer = Timer()

        func runSOSStep() {
            guard strobeTimer != nil else { return }
            let isOn = index % 2 == 0
            self.setTorchInternal(isOn: isOn)
            let delay = sosPattern[index % sosPattern.count]
            index = (index + 1) % sosPattern.count

            // Corrected: Capture the local function directly
            strobeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                runSOSStep()
            }
        }
        runSOSStep()
    }

    private func setTorchInternal(isOn: Bool, level: Float? = nil) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isOn {
                try device.setTorchModeOn(level: max(0.001, min(level ?? self.intensity, 1.0)))
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch { }
    }

    func stopStrobe() {
        strobeTimer?.invalidate()
        strobeTimer = nil
        setTorchInternal(isOn: false)
    }

    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func triggerSelectionFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
