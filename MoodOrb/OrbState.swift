import SwiftUI
import UIKit

// MARK: - OrbState

final class OrbState: ObservableObject {
    @Published var isPressing: Bool = false
    @Published var hasInteracted: Bool = false
    @Published var sessionTime: Double = 0.0

    private var sessionTimer: Timer?
    private let haptics = HapticManager()

    var orbColors: OrbColors {
        ColorPhase.colors(for: sessionTime)
    }

    func startInhale() {
        guard !isPressing else { return }
        isPressing = true
        haptics.inhaleImpact()
        if !hasInteracted {
            hasInteracted = true
            startSessionTimer()
        }
    }

    func startExhale() {
        guard isPressing else { return }
        isPressing = false
        haptics.exhaleImpact()
    }

    private func startSessionTimer() {
        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.sessionTime += 0.1
        }
    }

    deinit {
        sessionTimer?.invalidate()
    }
}

// MARK: - HapticManager

private final class HapticManager {
    private let softGenerator  = UIImpactFeedbackGenerator(style: .soft)
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)

    init() {
        softGenerator.prepare()
        lightGenerator.prepare()
    }

    func inhaleImpact() {
        softGenerator.impactOccurred(intensity: 0.65)
    }

    func exhaleImpact() {
        lightGenerator.impactOccurred(intensity: 0.40)
    }
}
