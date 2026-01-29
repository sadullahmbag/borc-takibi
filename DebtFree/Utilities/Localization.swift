import Foundation

extension String {
    var localized: String {
        let isTurkish = Locale.current.language.languageCode?.identifier == "tr"
        return isTurkish ? self.turkish : self
    }

    private var turkish: String {
        switch self {
        // App Name
        case "Borciva": return "Borciva"

        // Main Tabs
        case "Home": return "Ana Sayfa"
        case "Goals": return "Hedefler"
        case "Progress": return "İlerleme"
        case "Settings": return "Ayarlar"

        // Dashboard
        case "Total Debt": return "Toplam Borç"
        case "Total Paid": return "Toplam Ödenen"
        case "Active Debts": return "Aktif Borçlar"
        case "debts": return "borç"
        case "Level": return "Seviye"
        case "LVL": return "SEV"
        case "XP": return "DP"
        case "Current Streak": return "Güncel Seri"
        case "months": return "ay"
        case "month streak": return "aylık seri"
        case "Add Debt": return "Borç Ekle"
        case "No debts yet": return "Henüz borç yok"
        case "Add your first debt to start tracking": return "İlk borcunu ekleyerek takibe başla"
        case "Get Started": return "Başla"
        case "You're debt-free!": return "Borçsuz bir hayat!"
        case "Your Debt Journey": return "Borç Yolculuğun"
        case "Your Debts": return "Borçların"
        case "No Active Debts": return "Aktif Borç Yok"
        case "Tap the + button to add a new debt": return "Yeni borç eklemek için + butonuna bas"
        case "Add Your First Debt": return "İlk Borcunu Ekle"
        case "Delete Debt?": return "Borç Silinsin Mi?"
        case "Delete": return "Sil"
        case "Are you sure you want to delete this debt? This action cannot be undone.": return "Bu borcu silmek istediğinden emin misin? Bu işlem geri alınamaz."
        case "Total debt summary": return "Toplam borç özeti"
        case "Add new debt": return "Yeni borç ekle"

        // Debt Card
        case "Make Payment": return "Ödeme Yap"
        case "Complete": return "Tamamla"
        case "paid": return "ödendi"

        // Add Debt
        case "New Debt": return "Yeni Borç"
        case "Debt Name": return "Borç Adı"
        case "e.g., Credit Card": return "Örn: Kredi Kartı"
        case "Amount": return "Tutar"
        case "Category": return "Kategori"
        case "Due Date": return "Vade Tarihi"
        case "Interest Rate": return "Faiz Oranı"
        case "Optional": return "İsteğe Bağlı"
        case "Choose Emoji": return "Emoji Seç"
        case "Choose Color": return "Renk Seç"
        case "Create Debt": return "Borç Oluştur"
        case "Cancel": return "İptal"

        // Payment
        case "Payment Amount": return "Ödeme Tutarı"
        case "Pay Full Amount": return "Tamamını Öde"
        case "Note": return "Not"
        case "Add a note...": return "Not ekle..."
        case "Quick Amounts": return "Hızlı Tutarlar"
        case "Current Balance": return "Güncel Bakiye"

        // Goals
        case "Set Your First Goal": return "İlk Hedefini Belirle"
        case "Set goals to pay off your debts": return "Borçlarını ödemek için hedefler koy"
        case "Create smart goals to track your debt payoff journey": return "Borç ödeme sürecini takip etmek için akıllı hedefler oluştur"
        case "Add Goal": return "Hedef Ekle"
        case "Create Goal": return "Hedef Oluştur"
        case "Completed": return "Tamamlananlar"
        case "New Goal": return "Yeni Hedef"
        case "Goal Name": return "Hedef Adı"
        case "e.g., Pay off credit card": return "Örn: Kredi kartını öde"
        case "Target Amount": return "Hedef Tutar"
        case "Target Date": return "Hedef Tarih"
        case "days remaining": return "gün kaldı"
        case "complete": return "tamamlandı"

        // Gamification
        case "Level Progress": return "Seviye İlerlemesi"
        case "Experience": return "Deneyim"
        case "Active Challenges": return "Aktif Görevler"
        case "No challenges": return "Görev yok"
        case "Add Daily Challenge": return "Günlük Görev Ekle"
        case "Add Weekly Challenge": return "Haftalık Görev Ekle"
        case "hours left": return "saat kaldı"
        case "h left": return "s kaldı"

        // Achievements
        case "Your Stats": return "İstatistikleriniz"
        case "Achievements": return "Başarımlar"
        case "unlocked": return "açıldı"
        case "Debts Completed": return "Tamamlanan Borçlar"
        case "Longest Streak": return "En Uzun Seri"
        case "Visual Dashboard": return "Görsel Panel"
        case "See your progress in beautiful charts": return "İlerlemenizi güzel grafiklerle görün"
        case "Challenges & Rewards": return "Görevler & Ödüller"
        case "Complete challenges and earn power-ups": return "Görevleri tamamla ve ödüller kazan"

        // Settings
        case "Currency": return "Para Birimi"
        case "Select Currency": return "Para Birimi Seç"
        case "Theme": return "Tema"
        case "Light": return "Açık"
        case "Dark": return "Koyu"
        case "System": return "Sistem"
        case "Preferences": return "Tercihler"
        case "Celebrations": return "Kutlamalar"
        case "Haptic Feedback": return "Dokunsal Geri Bildirim"
        case "Notifications": return "Bildirimler"
        case "About": return "Hakkında"
        case "Version": return "Sürüm"
        case "Developer": return "Geliştirici"

        // Achievements Titles
        case "First Steps": return "İlk Adımlar"
        case "First payment made": return "İlk ödeme yapıldı"
        case "Getting Started": return "Başlangıç"
        case "Made 25 payments": return "25 ödeme yapıldı"
        case "Consistency": return "Tutarlılık"
        case "3-month payment streak": return "3 aylık ödeme serisi"
        case "Dedication": return "Kararlılık"
        case "6-month payment streak": return "6 aylık ödeme serisi"
        case "Year Warrior": return "Yıl Savaşçısı"
        case "12-month payment streak": return "12 aylık ödeme serisi"
        case "Persistence": return "Azim"
        case "Made 50 payments": return "50 ödeme yapıldı"
        case "Dedication Master": return "Kararlılık Ustası"
        case "Made 100 payments": return "100 ödeme yapıldı"
        case "Debt Slayer": return "Borç Avcısı"
        case "Paid off first debt": return "İlk borç ödendi"
        case "Debt Crusher": return "Borç Kırıcı"
        case "Paid off 3 debts": return "3 borç ödendi"
        case "Debt Master": return "Borç Ustası"
        case "Paid off 5 debts": return "5 borç ödendi"
        case "Debt Free Hero": return "Borçsuz Kahraman"
        case "Paid off 10 debts": return "10 borç ödendi"
        case "Small Wins": return "Küçük Zaferler"
        case "Paid 5000₺ total": return "Toplam 5000₺ ödendi"
        case "Building Momentum": return "İvme Kazanma"
        case "Paid 25000₺ total": return "Toplam 25000₺ ödendi"
        case "Major Milestone": return "Büyük Kilometre Taşı"
        case "Paid 100000₺ total": return "Toplam 100000₺ ödendi"
        case "Financial Freedom": return "Mali Özgürlük"
        case "Paid 500000₺ total": return "Toplam 500000₺ ödendi"
        case "Level 5": return "Seviye 5"
        case "Reached level 5": return "Seviye 5'e ulaşıldı"
        case "Level 10": return "Seviye 10"
        case "Reached level 10": return "Seviye 10'a ulaşıldı"
        case "Level 20": return "Seviye 20"
        case "Reached level 20": return "Seviye 20'ye ulaşıldı"
        case "Level 50": return "Seviye 50"
        case "Reached level 50": return "Seviye 50'ye ulaşıldı"

        // Success Messages
        case "Great job!": return "Harika iş!"
        case "You paid": return "Ödeme yaptın:"
        case "Debt Completed!": return "Borç Tamamlandı!"
        case "is paid off!": return "ödendi!"
        case "Achievement Unlocked!": return "Başarım Kazanıldı!"
        case "Challenge Completed!": return "Görev Tamamlandı!"
        case "You earned": return "Kazandın:"
        case "Awesome!": return "Harika!"

        default:
            return self
        }
    }
}
