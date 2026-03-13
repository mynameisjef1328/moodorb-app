import SwiftUI

struct ContentView: View {
    @StateObject private var orbState = OrbState()
    @State private var showHint = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Full black canvas ──────────────────────────────────────
                Color.black.ignoresSafeArea()

                // ── Orb ───────────────────────────────────────────────────
                OrbView(state: orbState)

                // ── "Hold to breathe" hint — fades forever after first tap ─
                if showHint {
                    Text("hold to breathe")
                        .font(.system(size: 12, weight: .ultraLight, design: .default))
                        .foregroundColor(.white.opacity(0.38))
                        .kerning(5)
                        .offset(y: hintOffset(geo: geo))
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .preferredColorScheme(.dark)
        // ── Detect press + release anywhere on screen ───────────────────
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !orbState.isPressing else { return }
                    orbState.startInhale()
                    if showHint {
                        withAnimation(.easeOut(duration: 1.6)) {
                            showHint = false
                        }
                    }
                }
                .onEnded { _ in
                    orbState.startExhale()
                }
        )
    }

    private func hintOffset(geo: GeometryProxy) -> CGFloat {
        // Place label below the orb — roughly 42 % down from center
        min(geo.size.height, geo.size.width) * 0.44
    }
}

#Preview {
    ContentView()
}
