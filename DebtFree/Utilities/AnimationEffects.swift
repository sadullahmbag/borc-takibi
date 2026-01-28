import SwiftUI

// MARK: - Breathing Animation (Headspace-style)
struct BreathingCircle: View {
    @State private var isBreathing = false
    let color: Color

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: isBreathing ? 120 : 80, height: isBreathing ? 120 : 80)
            .opacity(isBreathing ? 1.0 : 0.7)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                }
            }
    }
}

// MARK: - Number Count Animation
struct AnimatedNumber: View {
    let value: Double
    @State private var displayValue: Double = 0

    var body: some View {
        Text(String(format: "%.2f", displayValue))
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: 1.5)) {
                    displayValue = newValue
                }
            }
    }
}

// MARK: - Shrinking Debt Animation
struct ShrinkingDebtView: View {
    let fromAmount: Double
    let toAmount: Double
    let color: Color
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var currentAmount: Double = 0
    @State private var scale: CGFloat = 1.2

    var body: some View {
        VStack(spacing: 12) {
            // Shrinking circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150 * scale, height: 150 * scale)
                .overlay(
                    VStack(spacing: 4) {
                        Text(currencyManager.format(currentAmount))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
                .shadow(color: color.opacity(0.4), radius: 20, x: 0, y: 10)

            Text("Debt Shrinking!")
                .font(.headline)
                .foregroundColor(color)
        }
        .onAppear {
            animateShrinking()
        }
    }

    private func animateShrinking() {
        currentAmount = fromAmount

        // Animate the number
        withAnimation(.easeInOut(duration: 2.0)) {
            currentAmount = toAmount
        }

        // Animate the scale
        withAnimation(
            .spring(response: 2.0, dampingFraction: 0.6)
        ) {
            scale = toAmount / fromAmount
        }

        // Add bounce effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale *= 1.1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale *= 0.91 // Return to proper size
                }
            }
        }
    }
}

// MARK: - Emoji Reaction Overlay
struct EmojiReaction: View {
    let emoji: String
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Text(emoji)
            .font(.system(size: 60))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.2
                    opacity = 1
                }

                withAnimation(.easeOut(duration: 2.0).delay(0.5)) {
                    offset = -100
                    opacity = 0
                }
            }
    }
}

// MARK: - Success Checkmark Animation
struct AnimatedCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 100, height: 100)
                .scaleEffect(scale)

            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: 100, height: 100)
                .scaleEffect(scale)

            Image(systemName: "checkmark")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(color)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 360
            }
        }
    }
}

// MARK: - Progress Bar with Particles
struct ParticleProgressBar: View {
    let progress: Double
    let color: Color
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)

                // Progress fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 12)
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)

                // Particles
                ForEach(particles) { particle in
                    Circle()
                        .fill(color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
        }
        .frame(height: 12)
        .onChange(of: progress) { oldValue, newValue in
            if newValue > oldValue {
                emitParticles()
            }
        }
    }

    private func emitParticles() {
        HapticManager.shared.light()

        for _ in 0..<5 {
            let particle = Particle(
                x: CGFloat.random(in: 0...300),
                y: 6,
                size: CGFloat.random(in: 3...8),
                opacity: 1.0
            )
            particles.append(particle)

            // Animate particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeOut(duration: 1.0)) {
                    if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                        particles[index].y = -20
                        particles[index].opacity = 0
                    }
                }
            }

            // Remove particle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                particles.removeAll { $0.id == particle.id }
            }
        }
    }

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
    }
}

// MARK: - Confetti Burst
struct ConfettiBurst: View {
    @State private var pieces: [ConfettiPiece] = []
    let colors: [Color] = [.pink, .purple, .blue, .orange, .yellow, .green]

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .opacity(piece.opacity)
                    .rotationEffect(.degrees(piece.rotation))
            }
        }
        .onAppear {
            createConfetti()
        }
    }

    private func createConfetti() {
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                size: CGFloat.random(in: 8...15),
                color: colors.randomElement()!,
                opacity: 1.0,
                rotation: 0
            )
            pieces.append(piece)

            animatePiece(piece)
        }
    }

    private func animatePiece(_ piece: ConfettiPiece) {
        let angle = Double.random(in: 0...(2 * .pi))
        let distance = CGFloat.random(in: 100...300)
        let endX = piece.x + cos(angle) * distance
        let endY = piece.y + sin(angle) * distance

        withAnimation(
            .easeOut(duration: Double.random(in: 1.5...3.0))
        ) {
            if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
                pieces[index].x = endX
                pieces[index].y = endY
                pieces[index].opacity = 0
                pieces[index].rotation = Double.random(in: 0...720)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            pieces.removeAll { $0.id == piece.id }
        }
    }

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var opacity: Double
        var rotation: Double
    }
}

// MARK: - Ripple Effect
struct RippleEffect: View {
    @State private var ripples: [Ripple] = []

    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(ColorTheme.pink.opacity(ripple.opacity), lineWidth: 2)
                    .frame(width: ripple.scale, height: ripple.scale)
            }
        }
        .onAppear {
            createRipple()
        }
    }

    private func createRipple() {
        for i in 0..<3 {
            let ripple = Ripple(scale: 0, opacity: 0.7)
            ripples.append(ripple)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeOut(duration: 1.5)) {
                    if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                        ripples[index].scale = 200
                        ripples[index].opacity = 0
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(i) * 0.2) {
                ripples.removeAll { $0.id == ripple.id }
            }
        }
    }

    struct Ripple: Identifiable {
        let id = UUID()
        var scale: CGFloat
        var opacity: Double
    }
}

// MARK: - Loading Dots Animation
struct LoadingDots: View {
    @State private var isAnimating = false
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Floating Card Animation
struct FloatingCard<Content: View>: View {
    let content: Content
    @State private var offset: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = -10
                }
            }
    }
}

// MARK: - Pulse Animation
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 4)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulseEffect(color: Color = ColorTheme.pink) -> some View {
        modifier(PulseEffect(color: color))
    }
}

// MARK: - Success Animation Overlay
struct SuccessAnimationOverlay: View {
    @Binding var isPresented: Bool
    let message: String
    let color: Color
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .opacity(opacity)

                VStack(spacing: 24) {
                    AnimatedCheckmark(color: color)

                    Text(message)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ConfettiBurst()
                        .frame(height: 200)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                        scale = 0.5
                    }
                }
            }
        }
    }
}
