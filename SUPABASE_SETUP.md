# Supabase Database Setup Instructions

Follow these steps to set up the database schema in your Supabase project:

## 1. Access SQL Editor

1. Log in to your Supabase dashboard at https://supabase.com
2. Select your project (the one with URL: https://xkgwttlftnlmtrbbezoh.supabase.co)
3. In the left sidebar, click on "SQL Editor"

## 2. Create New Query

1. Click on "New Query" button
2. Copy and paste the contents of the `supabase_setup.sql` file into the SQL editor
3. Click "Run" to execute the SQL commands

## 3. Verify Table Creation

1. In the left sidebar, click on "Table Editor"
2. You should see a `recipes` table in the list
3. Click on the table to verify the columns match the schema:
   - id (UUID, primary key)
   - user_id (UUID)
   - name (text)
   - description (text)
   - ingredients (text array)
   - created_at (timestamp with timezone)

## 4. Verify RLS Policies

1. In the left sidebar, click on "Authentication" and then "Policies"
2. Find the `recipes` table in the list
3. Verify that the following policies exist:
   - "Users can view their own recipes" (SELECT)
   - "Users can insert their own recipes" (INSERT)
   - "Users can update their own recipes" (UPDATE)
   - "Users can delete their own recipes" (DELETE)

## Important Notes

- The Row Level Security (RLS) policies ensure that users can only access their own recipes
- Each recipe is linked to a user via the `user_id` column, which should match the user's `auth.uid()`
- The Supabase client in your Flutter app is already configured to use your project URL and anon key

If you need to modify the schema later, you can create a new SQL query in the Supabase SQL Editor.
