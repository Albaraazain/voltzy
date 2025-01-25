CREATE OR REPLACE FUNCTION notify_professionals_for_broadcast_request()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.request_type = 'broadcast' AND NEW.status = 'awaiting_acceptance' THEN
        -- Insert initial status
        INSERT INTO job_status_history (job_id, status, created_by)
        VALUES (NEW.id, 'awaiting_acceptance', (
            SELECT profile_id FROM homeowners WHERE id = NEW.homeowner_id
        ));

        -- Create notifications for nearby professionals with the required service
        INSERT INTO notifications (professional_id, title, message, type)
        SELECT 
            p.id,
            'New Job Request',
            format('New %s job request within %.1f km of your location', 
                  (SELECT name FROM services WHERE id = NEW.service_id),
                  NEW.radius_km),
            'job_request'
        FROM professionals p
        WHERE 
            -- Check if professional offers the service
            p.services @> format('[{"id": "%s"}]', NEW.service_id)::jsonb
            -- Check if professional is verified and available
            AND p.is_verified = true
            AND p.is_available = true
            -- Check if professional is within radius using geography type
            AND ST_DWithin(
                ST_SetSRID(ST_MakePoint(p.location_lng, p.location_lat), 4326)::geography,
                ST_SetSRID(ST_MakePoint(NEW.location_lng, NEW.location_lat), 4326)::geography,
                NEW.radius_km * 1000  -- Convert km to meters
            );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS broadcast_job_notifications ON jobs;

-- Create trigger
CREATE TRIGGER broadcast_job_notifications
    AFTER INSERT ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION notify_professionals_for_broadcast_request(); 