-- Create function for atomic job status updates
CREATE OR REPLACE FUNCTION update_job_status(
  job_id UUID,
  new_status TEXT,
  professional_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_status TEXT;
  current_professional_id UUID;
BEGIN
  -- Get current job status with row lock
  SELECT status, professional_id INTO current_status, current_professional_id
  FROM jobs
  WHERE id = job_id
  FOR UPDATE;

  -- Validate status exists
  IF current_status IS NULL THEN
    RAISE EXCEPTION 'Job not found';
  END IF;

  -- Validate user has permission
  IF NOT (
    auth.uid() IN (
      SELECT profile_id FROM homeowners WHERE id = (SELECT homeowner_id FROM jobs WHERE id = job_id)
      UNION
      SELECT profile_id FROM professionals WHERE id = COALESCE(professional_id, (SELECT professional_id FROM jobs WHERE id = job_id))
    )
  ) THEN
    RAISE EXCEPTION 'Permission denied';
  END IF;

  -- Validate status transition
  IF NOT EXISTS (
    SELECT 1 FROM (
      VALUES
        ('pending', ARRAY['active', 'cancelled']),
        ('active', ARRAY['in_progress', 'cancelled']),
        ('in_progress', ARRAY['completed', 'cancelled']),
        ('completed', ARRAY[]::text[]),
        ('cancelled', ARRAY[]::text[]),
        ('awaiting_acceptance', ARRAY['active', 'cancelled']),
        ('scheduled', ARRAY['active', 'cancelled']),
        ('started', ARRAY['in_progress', 'cancelled'])
    ) AS valid_transitions (current_status, allowed_next_states)
    WHERE valid_transitions.current_status = current_status
    AND (
      new_status = current_status OR  -- Allow same status
      new_status = ANY(valid_transitions.allowed_next_states)
    )
  ) THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', current_status, new_status;
  END IF;

  -- Update job
  UPDATE jobs
  SET 
    status = new_status,
    professional_id = COALESCE(professional_id, current_professional_id),
    updated_at = CURRENT_TIMESTAMP
  WHERE id = job_id;

  -- Notify relevant parties
  PERFORM pg_notify(
    'job_status_changed',
    json_build_object(
      'job_id', job_id,
      'old_status', current_status,
      'new_status', new_status,
      'professional_id', COALESCE(professional_id, current_professional_id)
    )::text
  );
END;
$$; 