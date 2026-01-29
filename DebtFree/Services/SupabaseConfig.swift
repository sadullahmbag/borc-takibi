import Foundation
import Supabase

class SupabaseConfig {
    static let shared = SupabaseConfig()

    // MARK: - Supabase Configuration
    // TODO: Replace these with your actual Supabase project URL and anon key
    private let supabaseURL = "YOUR_SUPABASE_URL" // e.g., "https://xxxxx.supabase.co"
    private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    lazy var client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
    }()

    private init() {}
}
