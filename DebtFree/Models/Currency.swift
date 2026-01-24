import Foundation

struct Currency: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let code: String

    static let usd = Currency(id: "USD", name: "US Dollar", symbol: "$", code: "USD")
    static let eur = Currency(id: "EUR", name: "Euro", symbol: "€", code: "EUR")
    static let gbp = Currency(id: "GBP", name: "British Pound", symbol: "£", code: "GBP")
    static let jpy = Currency(id: "JPY", name: "Japanese Yen", symbol: "¥", code: "JPY")
    static let cny = Currency(id: "CNY", name: "Chinese Yuan", symbol: "¥", code: "CNY")
    static let inr = Currency(id: "INR", name: "Indian Rupee", symbol: "₹", code: "INR")
    static let rub = Currency(id: "RUB", name: "Russian Ruble", symbol: "₽", code: "RUB")
    static let brl = Currency(id: "BRL", name: "Brazilian Real", symbol: "R$", code: "BRL")
    static let cad = Currency(id: "CAD", name: "Canadian Dollar", symbol: "C$", code: "CAD")
    static let aud = Currency(id: "AUD", name: "Australian Dollar", symbol: "A$", code: "AUD")
    static let chf = Currency(id: "CHF", name: "Swiss Franc", symbol: "Fr", code: "CHF")
    static let krw = Currency(id: "KRW", name: "South Korean Won", symbol: "₩", code: "KRW")
    static let mxn = Currency(id: "MXN", name: "Mexican Peso", symbol: "Mex$", code: "MXN")
    static let sek = Currency(id: "SEK", name: "Swedish Krona", symbol: "kr", code: "SEK")
    static let nok = Currency(id: "NOK", name: "Norwegian Krone", symbol: "kr", code: "NOK")
    static let try_ = Currency(id: "TRY", name: "Turkish Lira", symbol: "₺", code: "TRY")
    static let sar = Currency(id: "SAR", name: "Saudi Riyal", symbol: "﷼", code: "SAR")
    static let aed = Currency(id: "AED", name: "UAE Dirham", symbol: "د.إ", code: "AED")
    static let zar = Currency(id: "ZAR", name: "South African Rand", symbol: "R", code: "ZAR")
    static let sgd = Currency(id: "SGD", name: "Singapore Dollar", symbol: "S$", code: "SGD")

    static let allCurrencies: [Currency] = [
        .usd, .eur, .gbp, .try_, .jpy, .cny, .inr, .rub, .brl, .cad,
        .aud, .chf, .krw, .mxn, .sek, .nok, .sar, .aed, .zar, .sgd
    ]

    func format(_ amount: Double, showCode: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)

        if showCode {
            return "\(symbol)\(formattedAmount) \(code)"
        } else {
            return "\(symbol)\(formattedAmount)"
        }
    }
}

// MARK: - Currency Manager
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()

    @Published var selectedCurrency: Currency {
        didSet {
            saveCurrency()
        }
    }

    private let currencyKey = "selectedCurrency"

    private init() {
        if let data = UserDefaults.standard.data(forKey: currencyKey),
           let currency = try? JSONDecoder().decode(Currency.self, from: data) {
            self.selectedCurrency = currency
        } else {
            self.selectedCurrency = .usd
        }
    }

    private func saveCurrency() {
        if let data = try? JSONEncoder().encode(selectedCurrency) {
            UserDefaults.standard.set(data, forKey: currencyKey)
        }
    }

    func format(_ amount: Double, showCode: Bool = false) -> String {
        selectedCurrency.format(amount, showCode: showCode)
    }
}
