import SwiftUI
import SwiftData

@main
struct DebtFreeApp: App {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
