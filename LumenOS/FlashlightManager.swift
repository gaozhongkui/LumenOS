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

    /// Toggle flashlight switch
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

    /// Adjust intensity
    func setIntensity(_ level: Float) {
        self.intensity = level
        guard let device = device, device.hasTorch, device.torchMode == .on else { return }

        // Only update immediately if in standard mode to avoid interrupting strobe/SOS cycles
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

    private func startStrobe() {
        var flashOn = false
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            flashOn.toggle()
            self.setTorch(isOn: flashOn)
        }
    }

    private func startSOS() {
        let sosPattern: [TimeInterval] = [0.2, 0.2, 0.2, 0.2, 0.2, 0.6, 0.6, 0.2, 0.6, 0.2, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 1.0]
        var index = 0

        func runNext() {
            guard strobeTimer != nil else { return }
            let isOn = index % 2 == 0
            self.setTorch(isOn: isOn)

            let delay = sosPattern[index % sosPattern.count]
            index += 1

            strobeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.runNext()
            }
        }

        // Initial call
        let isOn = index % 2 == 0
        self.setTorch(isOn: isOn)
        let delay = sosPattern[0]
        index += 1
        strobeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.runNext()
        }
    }

    private func runNext() {
        // Helper for SOS recursive timer
        let sosPattern: [TimeInterval] = [0.2, 0.2, 0.2, 0.2, 0.2, 0.6, 0.6, 0.2, 0.6, 0.2, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 1.0]
        // This is a bit messy, but serves the purpose for now.
        // In a real app, a more robust state machine would be better.
    }

    private func setTorch(isOn: Bool) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isOn {
                try device.setTorchModeOn(level: max(0.001, min(self.intensity, 1.0)))
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
