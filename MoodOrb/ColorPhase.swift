import SwiftUI

// MARK: - OrbColors

struct OrbColors {
    let inner: Color
    let mid: Color
    let outer: Color
    let glow: Color
}

// MARK: - Color Phase Data

private struct PhaseColorValues {
    // Each channel tuple: (red, green, blue, opacity)
    let inner: (Double, Double, Double, Double)
    let mid:   (Double, Double, Double, Double)
    let outer: (Double, Double, Double, Double)
    let glow:  (Double, Double, Double, Double)

    func toOrbColors() -> OrbColors {
        OrbColors(
            inner: Color(red: inner.0, green: inner.1, blue: inner.2, opacity: inner.3),
            mid:   Color(red: mid.0,   green: mid.1,   blue: mid.2,   opacity: mid.3),
            outer: Color(red: outer.0, green: outer.1, blue: outer.2, opacity: outer.3),
            glow:  Color(red: glow.0,  green: glow.1,  blue: glow.2,  opacity: glow.3)
        )
    }
}

// MARK: - ColorPhase

enum ColorPhase {
    // (sessionSeconds, PhaseColorValues)
    private static let keyframes: [(Double, PhaseColorValues)] = [
        // 0s — Cool electric blue
        (0, PhaseColorValues(
            inner: (0.50, 0.85, 1.00, 1.0),
            mid:   (0.05, 0.42, 0.82, 1.0),
            outer: (0.01, 0.10, 0.30, 1.0),
            glow:  (0.25, 0.62, 1.00, 1.0)
        )),
        // 60s — Soft teal
        (60, PhaseColorValues(
            inner: (0.28, 0.92, 0.88, 1.0),
            mid:   (0.00, 0.58, 0.62, 1.0),
            outer: (0.00, 0.18, 0.24, 1.0),
            glow:  (0.12, 0.82, 0.78, 1.0)
        )),
        // 120s — Warm gold
        (120, PhaseColorValues(
            inner: (1.00, 0.88, 0.42, 1.0),
            mid:   (0.90, 0.52, 0.04, 1.0),
            outer: (0.28, 0.12, 0.00, 1.0),
            glow:  (1.00, 0.72, 0.18, 1.0)
        )),
        // 180s — Deep violet
        (180, PhaseColorValues(
            inner: (0.82, 0.58, 0.98, 1.0),
            mid:   (0.42, 0.10, 0.68, 1.0),
            outer: (0.10, 0.02, 0.22, 1.0),
            glow:  (0.65, 0.32, 0.92, 1.0)
        )),
    ]

    static func colors(for sessionTime: Double) -> OrbColors {
        let t = min(sessionTime, 240.0)

        // Find surrounding keyframes
        var lowerIdx = 0
        for (i, kf) in keyframes.enumerated() where kf.0 <= t {
            lowerIdx = i
        }
        let upperIdx = min(lowerIdx + 1, keyframes.count - 1)

        if lowerIdx == upperIdx {
            return keyframes[lowerIdx].1.toOrbColors()
        }

        let lowerTime = keyframes[lowerIdx].0
        let upperTime = keyframes[upperIdx].0
        let fraction  = (t - lowerTime) / (upperTime - lowerTime)

        return interpolate(
            from: keyframes[lowerIdx].1,
            to:   keyframes[upperIdx].1,
            t:    fraction
        )
    }

    // MARK: Private

    private static func interpolate(
        from: PhaseColorValues,
        to:   PhaseColorValues,
        t:    Double
    ) -> OrbColors {
        OrbColors(
            inner: lerp(from.inner, to.inner, t: t),
            mid:   lerp(from.mid,   to.mid,   t: t),
            outer: lerp(from.outer, to.outer, t: t),
            glow:  lerp(from.glow,  to.glow,  t: t)
        )
    }

    private static func lerp(
        _ a: (Double, Double, Double, Double),
        _ b: (Double, Double, Double, Double),
        t:   Double
    ) -> Color {
        Color(
            red:     a.0 + (b.0 - a.0) * t,
            green:   a.1 + (b.1 - a.1) * t,
            blue:    a.2 + (b.2 - a.2) * t,
            opacity: a.3 + (b.3 - a.3) * t
        )
    }
}
