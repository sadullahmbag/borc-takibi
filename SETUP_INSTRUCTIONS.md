# DebtFree App - Setup Instructions

## 📦 Initial Setup

### 1. Clone the Repository
```bash
git clone -b claude/debt-tracker-app-4pEll https://github.com/sadullahmbag/borc-takibi.git
cd borc-takibi
```

### 2. Add Supabase Swift Package Dependency

The project requires the Supabase Swift SDK for authentication and cloud sync features.

#### Steps to Add Package in Xcode:

1. **Open the project**:
   ```bash
   open DebtFree.xcodeproj
   ```

2. **Navigate to Package Dependencies**:
   - Select the **DebtFree** project (blue icon) in the Project Navigator
   - Select the **DebtFree** target
   - Click on the **"Package Dependencies"** tab

3. **Add Swift Package**:
   - Click the **"+"** button (bottom left)
   - Enter the package URL:
     ```
     https://github.com/supabase/supabase-swift
     ```
   - Click **"Add Package"**

4. **Configure Package Version**:
   - Dependency Rule: **"Up to Next Major Version"**
   - Version: **2.0.0** or later
   - Click **"Add Package"**

5. **Select Package Products**:
   - Check **"Supabase"** from the list
   - Click **"Add Package"**

### 3. Build the Project

1. **Clean Build Folder**:
   - Press **⌘+Shift+K** or
   - Menu: Product → Clean Build Folder

2. **Build the Project**:
   - Press **⌘+B** or
   - Menu: Product → Build

3. **Run the App**:
   - Press **⌘+R** or
   - Menu: Product → Run

## 🔐 Supabase Configuration

The app is already configured with a Supabase project. The configuration is in:
```
DebtFree/Services/SupabaseConfig.swift
```

For detailed Supabase setup instructions, see [SUPABASE_SETUP.md](SUPABASE_SETUP.md).

## ✅ Features Included

- ✅ Debt tracking with interest calculations
- ✅ Payment history and progress tracking
- ✅ Goals and milestones
- ✅ Analytics dashboard with charts
- ✅ Dark mode and customizable themes
- ✅ Push notifications for payment reminders
- ✅ Gamification with achievements and challenges
- ✅ Social sharing capabilities
- ✅ CSV/PDF export functionality
- ✅ Multi-currency support
- ✅ Apple Sign In integration
- ✅ Cloud sync via Supabase

## 🎯 Testing Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## 📝 Common Issues

### Issue: "No such module 'Supabase'"
**Solution**: Follow the steps above to add the Supabase Swift package dependency.

### Issue: Build fails after adding package
**Solution**:
1. Clean build folder (⌘+Shift+K)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Restart Xcode
4. Build again (⌘+B)

### Issue: Package resolution fails
**Solution**:
1. Check your internet connection
2. Try File → Packages → Reset Package Caches
3. Try File → Packages → Update to Latest Package Versions

## 📚 Additional Documentation

- [README.md](README.md) - App overview and features
- [FEATURES.md](FEATURES.md) - Detailed feature list
- [SUPABASE_SETUP.md](SUPABASE_SETUP.md) - Supabase configuration guide
- [APP_SUMMARY.md](APP_SUMMARY.md) - Technical architecture summary

## 🆘 Need Help?

If you encounter any issues not covered here, please:
1. Check the existing documentation files
2. Verify all dependencies are properly installed
3. Ensure you're using the correct iOS and Xcode versions
