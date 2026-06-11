import AVFoundation
import UIKit
import SwiftUI
import Combine

final class FlashlightManager: ObservableObject {
    static let shared = FlashlightManager()

    private var device: AVCaptureDevice?
    private var strobeTimer: Timer?
    private var sosIndex = 0

    @Published var currentMode: FlashlightMode = .standard
    @Published var intensity: Float = 0.6

    init() {
        self.device = AVCaptureDevice.default(for: .video)
    }

    enum FlashlightMode: String, CaseIterable {
        case standard, sos, strobe, party, pulse, silent
    }

    /// Toggle flashlight switch with full logic
    func toggle(isOn: Bool, level: Float? = nil) {
        if let level = level {
            self.intensity = level
        }

        if !isOn {
            stopStrobe()
            return
        }

        // If already on and mode hasn't changed, we might not want to reset timers.
        // But usually, updateMode calls this when a change IS detected.

        restartCurrentMode()
    }

    func restartCurrentMode() {
        stopStrobe()

        guard let device = device, device.hasTorch else { return }

        switch currentMode {
        case .standard:
            setTorchInternal(isOn: true)
        case .sos:
            startSOS()
        case .strobe:
            startStrobe(interval: 0.1)
        case .party:
            startStrobe(interval: 0.05)
        case .pulse:
            startStrobe(interval: 0.4)
        case .silent:
            setTorchInternal(isOn: false) // Silent mode = off but "active"
        }
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

    private func startStrobe(interval: TimeInterval) {
        var flashOn = false
        strobeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            flashOn.toggle()
            self.setTorchInternal(isOn: flashOn)
        }
    }

    private func startSOS() {
        sosIndex = 0
        runSOSStep()
    }

    private func runSOSStep() {
        let sosPattern: [TimeInterval] = [0.2, 0.2, 0.2, 0.2, 0.2, 0.6, 0.6, 0.2, 0.6, 0.2, 0.6, 0.6, 0.2, 0.2, 0.2, 0.2, 0.2, 1.0]

        let isOn = sosIndex % 2 == 0
        self.setTorchInternal(isOn: isOn)

        let delay = sosPattern[sosIndex % sosPattern.count]
        sosIndex = (sosIndex + 1) % sosPattern.count

        strobeTimer?.invalidate()
        strobeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.runSOSStep()
        }
    }

    private func setTorchInternal(isOn: Bool, level: Float? = nil) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if isOn {
                let targetLevel = max(0.001, min(level ?? self.intensity, 1.0))
                try device.setTorchModeOn(level: targetLevel)
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
