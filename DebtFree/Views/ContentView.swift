import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                AchievementsView()
                    .tabItem {
                        Label("Progress", systemImage: "trophy.fill")
                    }
                    .tag(1)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(ColorTheme.pink)
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            .onAppear {
                setupTabBarAppearance()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
            }
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Adapt to color scheme - use softer dark mode background
        let backgroundColor = themeManager.currentTheme.colorScheme == .dark || systemColorScheme == .dark
            ? UIColor(Color(hex: "1C1C1E"))
            : UIColor(ColorTheme.cardBackground)

        appearance.backgroundColor = backgroundColor

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Debt.self, Payment.self, UserProgress.self], inMemory: true)
}
