-- Create the recipes table
CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  ingredients TEXT[] NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS recipes_user_id_idx ON recipes(user_id);
CREATE INDEX IF NOT EXISTS recipes_created_at_idx ON recipes(created_at);

-- Set up Row Level Security (RLS)
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- Create policies for row security
-- Policy for users to select only their own recipes
CREATE POLICY "Users can view their own recipes" ON recipes 
  FOR SELECT USING (auth.uid() = user_id);

-- Policy for users to insert their own recipes
CREATE POLICY "Users can insert their own recipes" ON recipes 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for users to update their own recipes
CREATE POLICY "Users can update their own recipes" ON recipes 
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy for users to delete their own recipes
CREATE POLICY "Users can delete their own recipes" ON recipes 
  FOR DELETE USING (auth.uid() = user_id);
