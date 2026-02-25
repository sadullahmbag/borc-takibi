import SwiftUI
import SwiftData

@main
struct BorcivaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Debt.self,
            Payment.self,
            UserProgress.self,
            AppSettings.self,
            Goal.self,
            Challenge.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            ColorTheme.dynamicBackground(colorScheme: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.purple, ColorTheme.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorTheme.purple))
                    .scaleEffect(1.5)
            }
        }
    }
}
