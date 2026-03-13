import SwiftUI

// MARK: - OrbView

struct OrbView: View {
    @ObservedObject var state: OrbState

    // Two independent scale layers — no animation conflict
    @State private var idlePulseScale: CGFloat = 1.0
    @State private var pressScale:     CGFloat = 1.0
    @State private var glowBreath:     CGFloat = 0.0

    private let orbSize: CGFloat = 280

    var body: some View {
        let colors        = state.orbColors
        let glowMagnitude = state.isPressing ? 1.2 : (0.6 + glowBreath * 0.4)

        ZStack {
            // ── Atmosphere layers (blurred halos) ──────────────────────────
            Circle()
                .fill(colors.glow)
                .frame(width: orbSize * 2.0)
                .blur(radius: 65)
                .opacity(0.07 * glowMagnitude)

            Circle()
                .fill(colors.glow)
                .frame(width: orbSize * 1.55)
                .blur(radius: 38)
                .opacity(0.14 * glowMagnitude)

            Circle()
                .fill(colors.glow)
                .frame(width: orbSize * 1.12)
                .blur(radius: 16)
                .opacity(0.28 * glowMagnitude)

            // ── Main orb body ───────────────────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors.inner, colors.mid, colors.outer],
                        center: .center,
                        startRadius: 0,
                        endRadius: orbSize * 0.5
                    )
                )
                .frame(width: orbSize, height: orbSize)

            // ── Inner luminous core overlay ─────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors.inner.opacity(0.55), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: orbSize * 0.28
                    )
                )
                .frame(width: orbSize, height: orbSize)

            // ── Bioluminescent particle shimmer ─────────────────────────────
            ParticleShimmerView()
                .frame(width: orbSize, height: orbSize)
                .clipShape(Circle())
                .blendMode(.screen)

            // ── Specular highlight (off-center top-left) ────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.42), .clear],
                        center: UnitPoint(x: 0.34, y: 0.30),
                        startRadius: 0,
                        endRadius: orbSize * 0.30
                    )
                )
                .frame(width: orbSize, height: orbSize)

            // ── Limbal edge glow ────────────────────────────────────────────
            Circle()
                .stroke(colors.inner.opacity(0.22), lineWidth: 1.5)
                .frame(width: orbSize - 1, height: orbSize - 1)
                .blur(radius: 1.5)
        }
        // Two scale effects multiply together cleanly
        .scaleEffect(idlePulseScale)
        .scaleEffect(pressScale)
        .onChange(of: state.isPressing) { pressing in
            withAnimation(
                .spring(
                    response:        pressing ? 3.8 : 5.8,
                    dampingFraction: pressing ? 0.60 : 0.72,
                    blendDuration:   0.3
                )
            ) {
                pressScale = pressing ? 1.30 : 1.0
            }
        }
        .onAppear {
            // Gentle idle pulse
            withAnimation(
                .easeInOut(duration: 3.6)
                .repeatForever(autoreverses: true)
            ) {
                idlePulseScale = 1.036
            }
            // Glow breathe
            withAnimation(
                .easeInOut(duration: 2.8)
                .repeatForever(autoreverses: true)
            ) {
                glowBreath = 1.0
            }
        }
    }
}

// MARK: - ParticleShimmerView

struct ParticleShimmerView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t  = timeline.date.timeIntervalSinceReferenceDate
                let cx = size.width  / 2
                let cy = size.height / 2
                let maxR = size.width / 2 * 0.88

                for i in 0..<32 {
                    let fi = Double(i)

                    // Golden-angle base angle + slow drift per particle
                    let baseAngle = fi * 2.3999632  // ≈ 2π / φ²
                    let drift     = t * 0.038 * (i.isMultiple(of: 2) ? 1.0 : -1.0)
                    let angle     = baseAngle + drift

                    // Sunflower radial distribution
                    let radFrac = (fi * 0.6180339).truncatingRemainder(dividingBy: 1.0)
                    let dist    = maxR * (0.06 + 0.90 * radFrac)

                    let x = cx + cos(angle) * dist
                    let y = cy + sin(angle) * dist

                    // Independent twinkle — squared for sharper flicker
                    let speed  = 0.70 + (fi.truncatingRemainder(dividingBy: 5.0)) * 0.38
                    let phase  = fi * 1.41
                    let raw    = (sin(t * speed + phase) + 1.0) / 2.0
                    let bright = raw * raw

                    let opacity = bright * 0.32
                    let pSize   = 1.2 + bright * 2.8

                    guard opacity > 0.025 else { continue }

                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - pSize / 2,
                            y: y - pSize / 2,
                            width: pSize,
                            height: pSize
                        )),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
    }
}
