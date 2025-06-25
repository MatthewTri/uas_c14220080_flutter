# Recipe Keeper App

A simple Flutter application for managing and storing personal cooking recipes.

## Features

- **Authentication**
  - Sign Up, Sign In, and Sign Out functionality using Supabase Auth
  - Input validation with error messages
  - Session persistence for automatic login

- **Recipe Management**
  - Create new recipes with name, description, and ingredients
  - View a list of saved recipes
  - Edit and delete existing recipes
  - Data stored in Supabase Database based on user ID

- **Get Started Screen**
  - Only appears on first launch
  - Uses SharedPreferences for tracking app state

- **Modern UI**
  - Clean, intuitive design
  - Responsive layout
  - Uses Flutter Bloc for state management

## Setup Instructions

### 1. Supabase Setup

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Set up authentication (Email provider)
4. Create a new table called `recipes` with the following columns:
   - `id` (UUID, primary key)
   - `user_id` (UUID, not null)
   - `name` (text, not null)
   - `description` (text)
   - `ingredients` (array of text)
   - `created_at` (timestamp with timezone, default: now())
5. Add Row Level Security (RLS) policy to ensure users can only access their own recipes

### 2. Configuration

1. Open `lib/core/services/supabase_service.dart`
2. Replace placeholder values with your actual Supabase credentials:
   ```dart
   static Future<void> initialize() async {
     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL', // Replace with your URL
       anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your key
     );
   }
   ```

### 3. Run the App

1. Install dependencies: `flutter pub get`
2. Run the app: `flutter run`

## Project Structure

- `/lib/core` - Core functionality, services, and shared utilities
- `/lib/features` - Feature-based modules using clean architecture
  - `/auth` - Authentication feature
  - `/recipe` - Recipe management feature
  - `/get_started` - Onboarding feature

## Technologies Used

- Flutter
- Supabase (Authentication & Database)
- Flutter Bloc (State Management)
- SharedPreferences (Session Persistence)
- Go Router (Navigation)


## Dummy Data

1. Username (email) : test@gmail.com
2. Password : password
