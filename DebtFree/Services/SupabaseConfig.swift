import Foundation
import Supabase

class SupabaseConfig {
    static let shared = SupabaseConfig()

    // MARK: - Supabase Configuration
    private let supabaseURL = "https://mqzglcruopbcudeldojt.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xemdsY3J1b3BiY3VkZWxkb2p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MDcwMjcsImV4cCI6MjA4NTI4MzAyN30.92lELVaPQHmGQsvdizCQvDnYb5oJcgJiMXfd1bkIuxA"

    lazy var client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
    }()

    private init() {}
}
