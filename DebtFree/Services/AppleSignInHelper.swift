import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI

class AppleSignInHelper: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentNonce: String?
    private var onSuccess: ((String, String) -> Void)?
    private var onError: ((Error) -> Void)?

    // Start Apple Sign In flow
    func signIn(onSuccess: @escaping (String, String) -> Void, onError: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onError = onError

        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    // Generate random nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    // SHA256 hash
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                onError?(AuthError.unknown(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: nonce is missing"])))
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                onError?(AuthError.unknown(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                onError?(AuthError.unknown(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"])))
                return
            }

            onSuccess?(idTokenString, nonce)
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        onError?(error)
    }
}
