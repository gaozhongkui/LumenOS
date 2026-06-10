import AVFoundation
import UIKit
import SwiftUI
import Combine

final class FlashlightManager: ObservableObject {
    static let shared = FlashlightManager()

    private var device: AVCaptureDevice?

    init() {
        self.device = AVCaptureDevice.default(for: .video)
    }

    /// 切换手电筒开关
    func toggle(isOn: Bool, level: Float = 1.0) {
        guard let device = device, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if isOn {
                // level 必须在 0.0 到 1.0 之间
                try device.setTorchModeOn(level: max(0.001, min(level, 1.0)))
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("手电筒无法配置: \(error)")
        }
    }

    /// 调节亮度
    func setIntensity(_ level: Float) {
        guard let device = device, device.hasTorch, device.torchMode == .on else { return }
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: max(0.001, min(level, 1.0)))
            device.unlockForConfiguration()
        } catch {
            print("亮度调节失败: \(error)")
        }
    }

    /// 触感反馈 - 震动
    func triggerHapticFeedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }

    /// 触感反馈 - 选择变化
    func triggerSelectionFeedback() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}
