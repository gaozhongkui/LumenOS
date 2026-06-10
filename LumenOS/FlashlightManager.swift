import AVFoundation
import UIKit
import SwiftUI
import Combine

final class FlashlightManager: ObservableObject {
    static let shared = FlashlightManager()

    private var device: AVCaptureDevice?
    private var strobeTimer: Timer?

    @Published var currentMode: FlashlightMode = .standard

    init() {
        self.device = AVCaptureDevice.default(for: .video)
    }

    enum FlashlightMode {
        case standard, sos, strobe
    }

    /// Toggle flashlight switch
    func toggle(isOn: Bool, level: Float = 1.0) {
        stopStrobe() // Stop all active strobe loops

        guard let device = device, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isOn {
                switch currentMode {
                case .standard:
                    try device.setTorchModeOn(level: max(0.001, min(level, 1.0)))
                case .sos:
                    device.unlockForConfiguration() // Unlock for timer control
                    startSOS(level: level)
                    return
                case .strobe:
                    device.unlockForConfiguration()
                    startStrobe(level: level)
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

    /// Adjust intensity
    func setIntensity(_ level: Float) {
        guard let device = device, device.hasTorch, device.torchMode == .on else { return }
        // In SOS/Strobe, intensity applies on next flash cycle
        if currentMode == .standard {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: max(0.001, min(level, 1.0)))
                device.unlockForConfiguration()
            } catch {
                print("Intensity adjustment failed: \(error)")
            }
        }
    }

    // MARK: - Strobe Logic

    private func startStrobe(level: Float) {
        var flashOn = false
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            flashOn.toggle()
            self.setTorch(isOn: flashOn, level: level)
        }
    }

    private func startSOS(level: Float) {
        let sosPattern: [TimeInterval] = [0.2, 0.2, 0.2, 0.2, 0.2, 0.6, 0.6, 0.2, 0.6, 0.2, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 1.0]
        var index = 0

        func runNext() {
            let isOn = index % 2 == 0
            self.setTorch(isOn: isOn, level: level)

            let delay = sosPattern[index % sosPattern.count]
            index += 1

            strobeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                runNext()
            }
        }
        runNext()
    }

    private func setTorch(isOn: Bool, level: Float) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isOn {
                try device.setTorchModeOn(level: max(0.001, min(level, 1.0)))
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch { }
    }

    private func stopStrobe() {
        strobeTimer?.invalidate()
        strobeTimer = nil
    }

    /// Haptic Feedback
    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func triggerSelectionFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
