# Supabase Authentication Setup Guide

This guide will help you set up Supabase authentication for the DebtFree app.

## Prerequisites

- A Supabase account (create one at [supabase.com](https://supabase.com))
- Xcode 15.0 or later
- iOS 17.0 or later

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in your project details:
   - **Project name**: DebtFree (or any name you prefer)
   - **Database password**: Choose a strong password
   - **Region**: Select the region closest to your users
4. Click "Create new project"
5. Wait for the project to be set up (this may take a few minutes)

## Step 2: Get Your Supabase Credentials

1. In your Supabase project dashboard, go to **Settings** → **API**
2. Copy the following credentials:
   - **Project URL**: This is your Supabase URL (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key**: This is your anon key (starts with `eyJ...`)

## Step 3: Add Supabase Swift SDK to Xcode

1. Open `DebtFree.xcodeproj` in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. In the search bar, enter: `https://github.com/supabase/supabase-swift`
4. Select the latest version (recommended: 2.5.0 or higher)
5. Click **Add Package**
6. Select the following products:
   - **Supabase**
   - **Auth** (automatically included)
   - **PostgREST** (automatically included)
   - **Storage** (optional, for future features)
   - **Realtime** (optional, for future features)
7. Click **Add Package** again

## Step 4: Configure Your Supabase Credentials

1. Open `DebtFree/Services/SupabaseConfig.swift`
2. Replace the placeholder values with your actual Supabase credentials:

```swift
private let supabaseURL = "YOUR_SUPABASE_URL" // Replace with your Supabase URL
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY" // Replace with your anon key
```

For example:
```swift
private let supabaseURL = "https://abcdefgh.supabase.co"
private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Step 5: Configure Email Authentication in Supabase

1. In your Supabase project dashboard, go to **Authentication** → **Providers**
2. Make sure **Email** provider is enabled
3. Configure email settings:
   - **Enable email confirmations**: Toggle on/off based on your preference
     - If ON: Users will need to confirm their email before signing in
     - If OFF: Users can sign in immediately after registration
4. Optionally, customize the email templates under **Authentication** → **Email Templates**

## Step 6: Build and Run

1. Build the project in Xcode (⌘ + B)
2. Run the app on a simulator or device (⌘ + R)
3. You should now see the login/signup screen!

## Testing Authentication

### Test Sign Up
1. Open the app
2. Tap "Sign Up"
3. Enter an email and password (minimum 8 characters)
4. Tap "Create Account"
5. If email confirmation is enabled, check your email for a confirmation link
6. If email confirmation is disabled, you'll be signed in immediately

### Test Sign In
1. On the login screen, enter your email and password
2. Tap "Sign In"
3. You should be logged in and see the main app

### Test Sign Out
1. Navigate to the **Settings** tab
2. Scroll down to the **Account** section
3. Tap "Sign Out"
4. Confirm the action
5. You should be returned to the login screen

## Security Notes

⚠️ **IMPORTANT**: Never commit your Supabase credentials to version control!

For production apps, consider:
- Using environment variables or `.xcconfig` files for credentials
- Storing credentials in a secure keychain
- Adding `SupabaseConfig.swift` to `.gitignore` if it contains real credentials

## Troubleshooting

### "Cannot find type 'SupabaseClient' in scope"
- Make sure you've added the Supabase Swift SDK package dependency in Xcode
- Clean and rebuild the project (⌘ + Shift + K, then ⌘ + B)

### "Invalid credentials" error
- Double-check that you've copied the correct Supabase URL and anon key
- Make sure there are no extra spaces or quotes in the credentials

### Email not received during sign up
- Check your spam/junk folder
- Verify that email settings are configured correctly in Supabase dashboard
- Check Supabase logs under **Authentication** → **Logs**

### "Email confirmation required" message
- This is expected if you have email confirmations enabled
- Check your email and click the confirmation link
- You can disable email confirmations in the Supabase dashboard if needed for development

## Features Implemented

✅ User registration (sign up)
✅ User login (sign in)
✅ User logout (sign out)
✅ Password reset
✅ Email confirmation support
✅ Persistent authentication state
✅ Loading states and error handling
✅ Beautiful UI with gradients and animations

## Next Steps

Consider implementing these additional features:
- Social authentication (Google, Apple, etc.)
- User profile management
- Password change functionality
- Multi-factor authentication (MFA)
- OAuth providers
- Sync user data with Supabase database

## Need Help?

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [Swift Documentation](https://developer.apple.com/documentation/swift)
