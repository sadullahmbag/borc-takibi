import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [
        ColorTheme.pink, ColorTheme.purple, ColorTheme.blue,
        ColorTheme.teal, ColorTheme.green, ColorTheme.yellow,
        ColorTheme.orange
    ]

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(color: colors.randomElement() ?? ColorTheme.pink)
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: -400...800) : -100
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...720) : 0))
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: Double.random(in: 1.5...2.5))
                        .delay(Double.random(in: 0...0.3)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let shapes = ["circle", "square", "triangle"]
    @State private var shape = "circle"

    var body: some View {
        Group {
            if shape == "circle" {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
            } else if shape == "square" {
                Rectangle()
                    .fill(color)
                    .frame(width: 10, height: 10)
            } else {
                Triangle()
                    .fill(color)
                    .frame(width: 10, height: 10)
            }
        }
        .onAppear {
            shape = shapes.randomElement() ?? "circle"
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    let message: String
    let emoji: String

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }

                VStack(spacing: 20) {
                    Text(emoji)
                        .font(.system(size: 80))
                        .scaleEffect(isPresented ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isPresented)

                    Text(message)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(ColorTheme.gradient1)
                            .cornerRadius(25)
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(40)
                .transition(.scale.combined(with: .opacity))

                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
    }
}
