-- Create error codes for job status updates
CREATE TYPE job_status_error AS ENUM (
  'JOB_NOT_FOUND',
  'INVALID_STATUS_TRANSITION',
  'PERMISSION_DENIED',
  'INVALID_PROFESSIONAL',
  'SYSTEM_ERROR'
);

-- Create table for job status update logs
CREATE TABLE IF NOT EXISTS job_status_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID NOT NULL REFERENCES jobs(id),
  old_status TEXT NOT NULL,
  new_status TEXT NOT NULL,
  professional_id UUID REFERENCES professionals(id),
  updated_by UUID NOT NULL REFERENCES auth.users(id),
  error_code job_status_error,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

-- Update the job status update function with error handling
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
  v_error_code job_status_error;
  v_error_message TEXT;
BEGIN
  -- Get current job status with row lock
  SELECT status, professional_id INTO current_status, current_professional_id
  FROM jobs
  WHERE id = job_id
  FOR UPDATE;

  BEGIN
    -- Validate job exists
    IF current_status IS NULL THEN
      v_error_code := 'JOB_NOT_FOUND';
      v_error_message := 'Job not found';
      RAISE EXCEPTION USING ERRCODE = 'JOB_NOT_FOUND';
    END IF;

    -- Validate user has permission
    IF NOT (
      auth.uid() IN (
        SELECT profile_id FROM homeowners WHERE id = (SELECT homeowner_id FROM jobs WHERE id = job_id)
        UNION
        SELECT profile_id FROM professionals WHERE id = COALESCE(professional_id, (SELECT professional_id FROM jobs WHERE id = job_id))
      )
    ) THEN
      v_error_code := 'PERMISSION_DENIED';
      v_error_message := 'User does not have permission to update this job';
      RAISE EXCEPTION USING ERRCODE = 'PERMISSION_DENIED';
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
      v_error_code := 'INVALID_STATUS_TRANSITION';
      v_error_message := format('Invalid status transition from %s to %s', current_status, new_status);
      RAISE EXCEPTION USING ERRCODE = 'INVALID_STATUS_TRANSITION';
    END IF;

    -- Update job
    UPDATE jobs
    SET 
      status = new_status,
      professional_id = COALESCE(professional_id, current_professional_id),
      updated_at = CURRENT_TIMESTAMP
    WHERE id = job_id;

    -- Log successful update
    INSERT INTO job_status_logs (
      job_id,
      old_status,
      new_status,
      professional_id,
      updated_by
    ) VALUES (
      job_id,
      current_status,
      new_status,
      COALESCE(professional_id, current_professional_id),
      auth.uid()
    );

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

  EXCEPTION
    WHEN OTHERS THEN
      -- Log error
      INSERT INTO job_status_logs (
        job_id,
        old_status,
        new_status,
        professional_id,
        updated_by,
        error_code,
        error_message
      ) VALUES (
        job_id,
        current_status,
        new_status,
        COALESCE(professional_id, current_professional_id),
        auth.uid(),
        COALESCE(v_error_code, 'SYSTEM_ERROR'),
        COALESCE(v_error_message, SQLERRM)
      );
      RAISE;
  END;
END;
$$; 