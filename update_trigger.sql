CREATE OR REPLACE FUNCTION handle_new_profile()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_type = 'homeowner' THEN
        INSERT INTO homeowners (
            profile_id,
            notification_job_updates,
            notification_messages,
            notification_payments,
            notification_promotions,
            created_at
        ) VALUES (
            NEW.id,
            true,
            true,
            true,
            false,
            CURRENT_TIMESTAMP
        );
    ELSIF NEW.user_type = 'professional' THEN
        INSERT INTO professionals (
            profile_id,
            rating,
            jobs_completed,
            hourly_rate,
            is_available,
            years_of_experience,
            is_verified,
            working_hours,
            payment_info,
            notification_preferences,
            created_at
        ) VALUES (
            NEW.id,
            0.0,
            0,
            0.0,
            true,
            0,
            false,
            '{}'::jsonb,
            '{"bank_name": null, "account_name": null, "account_type": null, "account_number": null, "routing_number": null}'::jsonb,
            '{"messages": true, "promotions": false, "job_updates": true, "weekly_summary": true, "payment_updates": true, "new_job_requests": true, "quiet_hours_enabled": false, "quiet_hours_end_hour": 7, "quiet_hours_end_minute": 0, "quiet_hours_start_hour": 22, "quiet_hours_start_minute": 0}'::jsonb,
            CURRENT_TIMESTAMP
        );
    END IF;
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'Error in handle_new_profile: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 