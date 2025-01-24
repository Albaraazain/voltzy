-- Add is_verified column to professionals table
ALTER TABLE professionals ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON professionals;
DROP POLICY IF EXISTS "Enable read access for verified professionals" ON professionals;
DROP POLICY IF EXISTS "Enable admin verification" ON professionals;

-- Create policies for professional visibility
CREATE POLICY "Enable read access for verified professionals" ON professionals
    FOR SELECT
    USING (
        -- Admins can see all professionals
        (auth.jwt() ->> 'role' = 'admin')
        OR
        -- Professionals can see their own profile
        (auth.uid()::uuid = profile_id)
        OR
        -- Homeowners can only see verified professionals
        (
            EXISTS (
                SELECT 1 FROM profiles 
                WHERE id = auth.uid()::uuid 
                AND user_type = 'homeowner'
            )
            AND is_verified = true
        )
        OR
        -- Allow read access for all verified professionals
        (is_verified = true)
    );

-- Create policy for admin to update verification status
CREATE POLICY "Enable admin verification" ON professionals
    FOR UPDATE
    USING (auth.jwt() ->> 'role' = 'admin'); 