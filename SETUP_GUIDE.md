# UAS Flutter - Recipe Keeper App Setup Guide

## Step 1: Supabase Database Setup

1. **Login to Supabase**
   - Go to https://supabase.com and log in to your account
   - Navigate to your project (URL: https://xkgwttlftnlmtrbbezoh.supabase.co)

2. **Run SQL Script**
   - Go to the SQL Editor section in your Supabase dashboard
   - Click on "New Query"
   - Open the `supabase_setup.sql` file in this project
   - Copy and paste its contents into the SQL Editor
   - Click "Run" to execute the SQL

3. **Verify Setup**
   - Go to the "Table Editor" section
   - Check that the `recipes` table exists with the correct columns:
     - `id` (UUID, primary key)
     - `user_id` (UUID)
     - `name` (text)
     - `description` (text)
     - `ingredients` (text array)
     - `created_at` (timestamp)
   - Go to "Authentication" → "Policies" to verify Row Level Security (RLS) is enabled

## Step 2: Run the App

1. **Make sure dependencies are installed**
   ```powershell
   flutter pub get
   ```

2. **Run the app**
   ```powershell
   flutter run
   ```

3. **Using VS Code**
   - Open the Command Palette (Ctrl+Shift+P)
   - Run "Tasks: Run Task"
   - Select "Flutter: Run App"

## Features Implemented

1. **Authentication**
   - Sign Up with email/password
   - Sign In with email/password
   - Sign Out
   - Input validation
   - Error messages

2. **Database**
   - Cloud storage with Supabase
   - User-specific data storage (RLS)

3. **Session Persistence**
   - Automatic login on restart
   - First-launch detection

4. **Get Started Screen**
   - Onboarding flow for first-time users

5. **Recipe Management**
   - Create recipes with name, description, and ingredients
   - View list of recipes
   - Edit existing recipes
   - Delete recipes

## Project Structure

- `/lib/core` - Common utilities, services, and themes
- `/lib/features` - Feature modules:
  - `/auth` - User authentication
  - `/recipe` - Recipe management
  - `/get_started` - Onboarding

## Tech Stack

- Flutter (UI framework)
- Supabase (Authentication & Database)
- Flutter Bloc (State Management)
- SharedPreferences (Local Storage)
- Go Router (Navigation)

## Need Help?

See the detailed SQL setup instructions in `SUPABASE_SETUP.md`
