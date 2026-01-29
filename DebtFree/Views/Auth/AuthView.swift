import SwiftUI

struct AuthView: View {
    @State private var showSignUp = false

    var body: some View {
        Group {
            if showSignUp {
                SignUpView(showSignUp: $showSignUp)
                    .transition(.move(edge: .trailing))
            } else {
                LoginView(showSignUp: $showSignUp)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: showSignUp)
    }
}

#Preview {
    AuthView()
}
