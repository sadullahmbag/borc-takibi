import Foundation
#if canImport(Supabase)
import Supabase
#endif

class SupabaseConfig {
    static let shared = SupabaseConfig()

    // MARK: - Supabase Configuration
    private let supabaseURL = "https://mqzglcruopbcudeldojt.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xemdsY3J1b3BiY3VkZWxkb2p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3MDcwMjcsImV4cCI6MjA4NTI4MzAyN30.92lELVaPQHmGQsvdizCQvDnYb5oJcgJiMXfd1bkIuxA"

    #if canImport(Supabase)
    lazy var client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
    }()
    #endif

    var isAvailable: Bool {
        #if canImport(Supabase)
        return true
        #else
        return false
        #endif
    }

    private init() {}
}
