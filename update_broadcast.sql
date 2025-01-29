CREATE OR REPLACE FUNCTION handle_broadcast_job() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.request_type = 'broadcast' AND NEW.status = 'awaiting_acceptance' THEN
        -- Create job professional requests for all eligible professionals
        INSERT INTO job_professional_requests (job_id, professional_id, status)
        SELECT 
            NEW.id,
            p.id,
            'awaiting_acceptance'
        FROM professionals p
        WHERE 
            p.is_verified = true 
            AND p.is_available = true
            AND p.hourly_rate <= NEW.price
            AND ST_DWithin(
                ST_MakePoint(p.location_lng, p.location_lat),
                ST_MakePoint(NEW.location_lng, NEW.location_lat),
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
    EXECUTE FUNCTION handle_broadcast_job(); 