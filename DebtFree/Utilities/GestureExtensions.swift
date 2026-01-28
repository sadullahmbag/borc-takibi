import SwiftUI

// MARK: - Swipe to Delete Modifier
struct SwipeToDeleteModifier: ViewModifier {
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    @GestureState private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            // Delete button background - only show when swiped
            if offset < 0 || dragOffset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            HapticManager.shared.warning()
                            onDelete()
                        }
                    }) {
                        VStack {
                            Image(systemName: "trash.fill")
                                .font(.title2)
                            Text("Delete")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80)
                    }
                    .frame(maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .transition(.move(edge: .trailing))
            }

            // Content
            content
                .background(Color.clear)
                .offset(x: offset + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.width < 0 {
                                state = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if value.translation.width < -100 {
                                    offset = -80
                                    HapticManager.shared.light()
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .clipped()
    }
}

extension View {
    func swipeToDelete(onDelete: @escaping () -> Void) -> some View {
        modifier(SwipeToDeleteModifier(onDelete: onDelete))
    }
}

// MARK: - Pull to Refresh
struct PullToRefreshModifier: ViewModifier {
    let coordinateSpaceName: String
    let onRefresh: () async -> Void

    @State private var isRefreshing = false

    func body(content: Content) -> some View {
        content
            .refreshable {
                await onRefresh()
            }
    }
}

extension View {
    func pullToRefresh(onRefresh: @escaping () async -> Void) -> some View {
        modifier(PullToRefreshModifier(coordinateSpaceName: "pullToRefresh", onRefresh: onRefresh))
    }
}

// MARK: - Long Press Menu
struct LongPressMenuModifier<MenuContent: View>: ViewModifier {
    let menuContent: MenuContent
    @State private var showMenu = false
    @State private var menuPosition: CGPoint = .zero

    init(@ViewBuilder menuContent: () -> MenuContent) {
        self.menuContent = menuContent()
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                menuContent
            }
            .onLongPressGesture {
                HapticManager.shared.medium()
            }
    }
}

extension View {
    func longPressMenu<MenuContent: View>(@ViewBuilder menuContent: @escaping () -> MenuContent) -> some View {
        modifier(LongPressMenuModifier(menuContent: menuContent))
    }
}

// MARK: - Bouncy Press Animation
struct BouncyPressStyle: ButtonStyle {
    let scale: CGFloat

    init(scale: CGFloat = 0.95) {
        self.scale = scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
    }
}

extension View {
    func bouncyPress(scale: CGFloat = 0.95) -> some View {
        buttonStyle(BouncyPressStyle(scale: scale))
    }
}

// MARK: - Shimmer Effect for Loading
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase)
                    .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Loading View
struct SkeletonView: View {
    let height: CGFloat
    let cornerRadius: CGFloat

    init(height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(height: height)
            .shimmer()
    }
}
