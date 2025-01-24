-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for own profile" ON "public"."profiles";
DROP POLICY IF EXISTS "Enable update for own profile" ON "public"."profiles";

-- Create new development policies for profiles
CREATE POLICY "Enable read access to all profiles" ON "public"."profiles"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable update for own profile" ON "public"."profiles"
AS PERMISSIVE FOR UPDATE
TO public
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policies for professionals table
DROP POLICY IF EXISTS "Enable read access for professionals" ON "public"."professionals";
DROP POLICY IF EXISTS "Enable update for own professional profile" ON "public"."professionals";

CREATE POLICY "Enable read access to all professionals" ON "public"."professionals"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable update for own professional profile" ON "public"."professionals"
AS PERMISSIVE FOR UPDATE
TO public
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

-- Policies for homeowners table
DROP POLICY IF EXISTS "Enable read access for homeowners" ON "public"."homeowners";
DROP POLICY IF EXISTS "Enable update for own homeowner profile" ON "public"."homeowners";

CREATE POLICY "Enable read access to all homeowners" ON "public"."homeowners"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable update for own homeowner profile" ON "public"."homeowners"
AS PERMISSIVE FOR UPDATE
TO public
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

-- Policies for jobs table
DROP POLICY IF EXISTS "Enable read access for jobs" ON "public"."jobs";
DROP POLICY IF EXISTS "Enable update for own jobs" ON "public"."jobs";

CREATE POLICY "Enable read access to all jobs" ON "public"."jobs"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable update for own jobs" ON "public"."jobs"
AS PERMISSIVE FOR UPDATE
TO public
USING (auth.uid() IN (
  SELECT profile_id FROM homeowners WHERE id = homeowner_id
  UNION
  SELECT profile_id FROM professionals WHERE id = professional_id
))
WITH CHECK (auth.uid() IN (
  SELECT profile_id FROM homeowners WHERE id = homeowner_id
  UNION
  SELECT profile_id FROM professionals WHERE id = professional_id
)); 