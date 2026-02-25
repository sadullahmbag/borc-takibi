# Fix Missing Files in Xcode Project

## Problem
Two Swift files exist in the repository but are not included in the Xcode project build:
- `DebtFree/Utilities/NotificationManager.swift`
- `DebtFree/Views/AnalyticsView.swift`

## Solution

### Step 1: Open Project
```bash
cd /Users/sadullah/borc-takibi
open DebtFree.xcodeproj
```

### Step 2: Add NotificationManager.swift

1. In Xcode's Project Navigator (left sidebar), locate the **"Utilities"** folder
2. Right-click on **"Utilities"** → Select **"Add Files to 'DebtFree'..."**
3. Navigate to: `DebtFree/Utilities/NotificationManager.swift`
4. **IMPORTANT**: UNCHECK **"Copy items if needed"** (the file already exists in the right location)
5. **IMPORTANT**: CHECK **"DebtFree"** under "Add to targets"
6. Click **"Add"**

### Step 3: Add AnalyticsView.swift

1. In Xcode's Project Navigator, locate the **"Views"** folder
2. Right-click on **"Views"** → Select **"Add Files to 'DebtFree'..."**
3. Navigate to: `DebtFree/Views/AnalyticsView.swift`
4. **IMPORTANT**: UNCHECK **"Copy items if needed"**
5. **IMPORTANT**: CHECK **"DebtFree"** under "Add to targets"
6. Click **"Add"**

### Step 4: Clean and Build

1. Clean Build Folder: **⌘+Shift+K** (or Product → Clean Build Folder)
2. Build: **⌘+B** (or Product → Build)
3. Run: **⌘+R** (or Product → Run)

## Verify Files Are Added

After adding the files, you can verify they're properly included:

1. Select the **DebtFree** project (blue icon at top of navigator)
2. Select the **DebtFree** target
3. Go to **"Build Phases"** tab
4. Expand **"Compile Sources"**
5. You should see both `NotificationManager.swift` and `AnalyticsView.swift` in the list

## Common Mistakes to Avoid

❌ **DON'T** check "Copy items if needed" - this will create duplicate files
❌ **DON'T** drag files from Finder - this often causes path issues
✅ **DO** use "Add Files to 'DebtFree'..." from the right-click menu
✅ **DO** make sure the DebtFree target is checked

## If You Still Get Errors

If you still see "Cannot find 'NotificationManager' in scope" after adding the files:

1. Quit Xcode completely (⌘+Q)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Reopen the project:
   ```bash
   open DebtFree.xcodeproj
   ```
4. Clean and build again (⌘+Shift+K, then ⌘+B)
