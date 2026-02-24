import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var userManager = UserManager.shared
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                GoalsView()
                    .tabItem {
                        Label("Goals", systemImage: "target")
                    }
                    .tag(1)

                AchievementsView()
                    .tabItem {
                        Label("Progress", systemImage: "trophy.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(ColorTheme.pink)
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            .onAppear {
                setupTabBarAppearance()
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
            }
            .overlay {
                if userManager.showWelcomePopup {
                    WelcomePopup {
                        userManager.showWelcomePopup = false
                    }
                }
            }
            .onAppear {
                // Check if this is a first-time user
                if let userId = authManager.userId {
                    userManager.checkFirstTimeUser(userId: userId)
                }

                // Request notification permissions
                Task {
                    await NotificationManager.shared.requestAuthorization()
                }
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
        .modelContainer(for: [Debt.self, Payment.self, UserProgress.self, Goal.self], inMemory: true)
}
