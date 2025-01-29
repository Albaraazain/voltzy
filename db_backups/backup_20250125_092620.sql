

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."contact_method" AS ENUM (
    'email',
    'phone',
    'sms'
);


ALTER TYPE "public"."contact_method" OWNER TO "postgres";


CREATE TYPE "public"."job_status_error" AS ENUM (
    'JOB_NOT_FOUND',
    'INVALID_STATUS_TRANSITION',
    'PERMISSION_DENIED',
    'INVALID_PROFESSIONAL',
    'SYSTEM_ERROR'
);


ALTER TYPE "public"."job_status_error" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_review_update"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Only allow professional to update their reply
    IF auth.uid() = (SELECT profile_id FROM professionals WHERE id = NEW.professional_id) THEN
        IF OLD.rating != NEW.rating OR 
           OLD.comment != NEW.comment OR 
           OLD.photos != NEW.photos OR 
           OLD.homeowner_id != NEW.homeowner_id OR 
           OLD.professional_id != NEW.professional_id OR 
           OLD.job_id != NEW.job_id THEN
            RAISE EXCEPTION 'Professional can only update their reply';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_review_update"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_slot_availability"("p_professional_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_conflicts INTEGER;
BEGIN
    -- Check for overlapping slots
    SELECT COUNT(*)
    INTO v_conflicts
    FROM schedule_slots
    WHERE professional_id = p_professional_id
    AND date = p_date
    AND status NOT IN ('CANCELLED')
    AND (
        (start_time, end_time) OVERLAPS (p_start_time, p_end_time)
    );

    RETURN v_conflicts = 0;
END;
$$;


ALTER FUNCTION "public"."check_slot_availability"("p_professional_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_pending_jobs"("professional_id" "uuid") RETURNS TABLE("count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
  RETURN QUERY
  SELECT COUNT(*)::BIGINT
  FROM jobs
  WHERE jobs.professional_id = $1
  AND jobs.status = 'pending';
END;
$_$;


ALTER FUNCTION "public"."count_pending_jobs"("professional_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_today_jobs"("professional_id" "uuid") RETURNS TABLE("count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
  RETURN QUERY
  SELECT COUNT(*)::BIGINT
  FROM jobs
  WHERE jobs.professional_id = $1
  AND DATE(jobs.date) = CURRENT_DATE;
END;
$_$;


ALTER FUNCTION "public"."count_today_jobs"("professional_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_unread_notifications"("profile_id" "uuid") RETURNS TABLE("count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
  RETURN QUERY
  SELECT COUNT(*)::BIGINT
  FROM notifications
  WHERE notifications.profile_id = $1
  AND notifications.is_read = false;
END;
$_$;


ALTER FUNCTION "public"."count_unread_notifications"("profile_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_booking"("p_professional_id" "uuid", "p_homeowner_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone, "p_description" "text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_job_id UUID;
    v_slot_id UUID;
BEGIN
    -- Check if slot is available
    IF NOT check_slot_availability(p_professional_id, p_date, p_start_time, p_end_time) THEN
        RAISE EXCEPTION 'Time slot is not available';
    END IF;

    -- Create job
    INSERT INTO jobs (
        professional_id,
        homeowner_id,
        status,
        description,
        title,
        price,
        date
    ) VALUES (
        p_professional_id,
        p_homeowner_id,
        'SCHEDULED',
        p_description,
        'Electrical Service',
        0.00, -- Price will be set by professional
        p_date::timestamp with time zone + p_start_time::time::interval
    ) RETURNING id INTO v_job_id;

    -- Create schedule slot
    INSERT INTO schedule_slots (
        professional_id,
        date,
        start_time,
        end_time,
        status,
        job_id
    ) VALUES (
        p_professional_id,
        p_date,
        p_start_time,
        p_end_time,
        'BOOKED',
        v_job_id
    ) RETURNING id INTO v_slot_id;

    RETURN v_job_id;
END;
$$;


ALTER FUNCTION "public"."create_booking"("p_professional_id" "uuid", "p_homeowner_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone, "p_description" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_table_info"("table_name" "text") RETURNS TABLE("column_name" "text", "data_type" "text", "is_nullable" boolean, "column_default" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
    RETURN QUERY
    SELECT 
        c.column_name::text,
        c.data_type::text,
        (c.is_nullable = 'YES') as is_nullable,
        c.column_default::text
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
    AND c.table_name = $1
    ORDER BY c.ordinal_position;
END;
$_$;


ALTER FUNCTION "public"."get_table_info"("table_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_job_status"("job_id" "uuid", "new_status" "text", "professional_id" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."update_job_status"("job_id" "uuid", "new_status" "text", "professional_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."calendar_events" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "calendar_sync_id" "uuid" NOT NULL,
    "external_event_id" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."calendar_events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."calendar_syncs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "provider" character varying(50) NOT NULL,
    "calendar_id" character varying(255) NOT NULL,
    "access_token" "text" NOT NULL,
    "refresh_token" "text",
    "last_synced_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."calendar_syncs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."direct_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "homeowner_id" "uuid" NOT NULL,
    "professional_id" "uuid" NOT NULL,
    "description" "text" NOT NULL,
    "preferred_date" "date" NOT NULL,
    "preferred_time" time without time zone NOT NULL,
    "status" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    "decline_reason" "text",
    "alternative_date" "date",
    "alternative_time" time without time zone,
    "alternative_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'DECLINED'::character varying])::"text"[])))
);


ALTER TABLE "public"."direct_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."homeowners" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid",
    "phone" "text",
    "address" "text",
    "preferred_contact_method" "public"."contact_method" DEFAULT 'email'::"public"."contact_method",
    "emergency_contact" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "notification_job_updates" boolean DEFAULT true,
    "notification_messages" boolean DEFAULT true,
    "notification_payments" boolean DEFAULT true,
    "notification_promotions" boolean DEFAULT false
);


ALTER TABLE "public"."homeowners" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_status_logs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "old_status" "text" NOT NULL,
    "new_status" "text" NOT NULL,
    "professional_id" "uuid",
    "updated_by" "uuid" NOT NULL,
    "error_code" "public"."job_status_error",
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE "public"."job_status_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jobs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "status" "text" NOT NULL,
    "date" timestamp with time zone NOT NULL,
    "homeowner_id" "uuid" NOT NULL,
    "professional_id" "uuid",
    "price" numeric(10,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "payment_status" "text" DEFAULT 'payment_pending'::"text" NOT NULL,
    "verification_status" "text" DEFAULT 'verification_pending'::"text" NOT NULL,
    "payment_details" "jsonb",
    "verification_details" "jsonb",
    CONSTRAINT "valid_payment_status" CHECK (("payment_status" = ANY (ARRAY['payment_pending'::"text", 'payment_processing'::"text", 'payment_completed'::"text", 'payment_failed'::"text", 'payment_refunded'::"text"]))),
    CONSTRAINT "valid_verification_status" CHECK (("verification_status" = ANY (ARRAY['verification_pending'::"text", 'verification_approved'::"text", 'verification_rejected'::"text"])))
);


ALTER TABLE "public"."jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "professional_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "type" "text" NOT NULL,
    "read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['job_request'::"text", 'job_update'::"text", 'payment'::"text", 'review'::"text", 'system'::"text"])))
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "status" "text" NOT NULL,
    "payment_method" "text" NOT NULL,
    "transaction_id" "text",
    "payer_id" "uuid" NOT NULL,
    "payee_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."professionals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "profile_id" "uuid",
    "rating" real DEFAULT 0.0,
    "jobs_completed" integer DEFAULT 0,
    "hourly_rate" real DEFAULT 0.0,
    "profile_image" "text",
    "is_available" boolean DEFAULT true,
    "specialties" "text"[],
    "license_number" "text",
    "years_of_experience" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "is_verified" boolean DEFAULT false,
    "phone" "text",
    "services" "jsonb" DEFAULT '[]'::"jsonb",
    "working_hours" "jsonb" DEFAULT '{}'::"jsonb",
    "payment_info" "jsonb" DEFAULT '{"bank_name": null, "account_name": null, "account_type": null, "account_number": null, "routing_number": null}'::"jsonb",
    "notification_preferences" "jsonb" DEFAULT '{"messages": true, "promotions": false, "job_updates": true, "weekly_summary": true, "payment_updates": true, "new_job_requests": true, "quiet_hours_enabled": false, "quiet_hours_end_hour": 7, "quiet_hours_end_minute": 0, "quiet_hours_start_hour": 22, "quiet_hours_start_minute": 0}'::"jsonb",
    CONSTRAINT "valid_hourly_rate" CHECK (("hourly_rate" >= (0)::double precision)),
    CONSTRAINT "valid_rating" CHECK ((("rating" >= (0)::double precision) AND ("rating" <= (5)::double precision))),
    CONSTRAINT "valid_years_of_experience" CHECK (("years_of_experience" >= 0))
);


ALTER TABLE "public"."professionals" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "user_type" "text" DEFAULT 'homeowner'::"text" NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "last_login_at" timestamp with time zone
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reschedule_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "requested_by_id" "uuid" NOT NULL,
    "requested_by_type" character varying(20) NOT NULL,
    "original_date" "date" NOT NULL,
    "original_time" time without time zone NOT NULL,
    "proposed_date" "date" NOT NULL,
    "proposed_time" time without time zone NOT NULL,
    "status" character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    "reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "valid_requested_by_type" CHECK ((("requested_by_type")::"text" = ANY ((ARRAY['HOMEOWNER'::character varying, 'PROFESSIONAL'::character varying])::"text"[]))),
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'DECLINED'::character varying])::"text"[])))
);


ALTER TABLE "public"."reschedule_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."review_responses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "review_id" "uuid" NOT NULL,
    "response" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."review_responses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "job_id" "uuid" NOT NULL,
    "reviewer_id" "uuid" NOT NULL,
    "reviewee_id" "uuid" NOT NULL,
    "reviewer_type" character varying(20) NOT NULL,
    "rating" integer NOT NULL,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "reviews_rating_check" CHECK ((("rating" >= 1) AND ("rating" <= 5)))
);


ALTER TABLE "public"."reviews" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schedule_slots" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "professional_id" "uuid" NOT NULL,
    "date" "date" NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "status" character varying(20) NOT NULL,
    "job_id" "uuid",
    "recurring_rule" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY ((ARRAY['AVAILABLE'::character varying, 'BOOKED'::character varying, 'BLOCKED'::character varying, 'PENDING'::character varying, 'CANCELLED'::character varying])::"text"[]))),
    CONSTRAINT "valid_times" CHECK (("start_time" < "end_time"))
);


ALTER TABLE "public"."schedule_slots" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."working_hours" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "professional_id" "uuid" NOT NULL,
    "day_of_week" integer NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "is_working_day" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "valid_working_hours" CHECK (("start_time" < "end_time")),
    CONSTRAINT "working_hours_day_of_week_check" CHECK ((("day_of_week" >= 0) AND ("day_of_week" <= 6)))
);


ALTER TABLE "public"."working_hours" OWNER TO "postgres";


ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_calendar_sync_id_external_event_id_key" UNIQUE ("calendar_sync_id", "external_event_id");



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."calendar_syncs"
    ADD CONSTRAINT "calendar_syncs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."direct_requests"
    ADD CONSTRAINT "direct_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."homeowners"
    ADD CONSTRAINT "homeowners_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."job_status_logs"
    ADD CONSTRAINT "job_status_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."professionals"
    ADD CONSTRAINT "professionals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reschedule_requests"
    ADD CONSTRAINT "reschedule_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."review_responses"
    ADD CONSTRAINT "review_responses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "reviews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."schedule_slots"
    ADD CONSTRAINT "schedule_slots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."working_hours"
    ADD CONSTRAINT "working_hours_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."working_hours"
    ADD CONSTRAINT "working_hours_professional_id_day_of_week_key" UNIQUE ("professional_id", "day_of_week");



CREATE INDEX "idx_calendar_events_calendar_sync_id" ON "public"."calendar_events" USING "btree" ("calendar_sync_id");



CREATE INDEX "idx_calendar_events_start_time" ON "public"."calendar_events" USING "btree" ("start_time");



CREATE INDEX "idx_calendar_syncs_profile_id" ON "public"."calendar_syncs" USING "btree" ("profile_id");



CREATE INDEX "idx_direct_requests_homeowner_id" ON "public"."direct_requests" USING "btree" ("homeowner_id");



CREATE INDEX "idx_direct_requests_preferred_date" ON "public"."direct_requests" USING "btree" ("preferred_date");



CREATE INDEX "idx_direct_requests_professional_id" ON "public"."direct_requests" USING "btree" ("professional_id");



CREATE INDEX "idx_direct_requests_status" ON "public"."direct_requests" USING "btree" ("status");



CREATE INDEX "idx_jobs_homeowner_id" ON "public"."jobs" USING "btree" ("homeowner_id");



CREATE INDEX "idx_jobs_payment_status" ON "public"."jobs" USING "btree" ("payment_status");



CREATE INDEX "idx_jobs_status" ON "public"."jobs" USING "btree" ("status");



CREATE INDEX "idx_jobs_verification_status" ON "public"."jobs" USING "btree" ("verification_status");



CREATE INDEX "idx_notifications_created_at" ON "public"."notifications" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_notifications_professional_id" ON "public"."notifications" USING "btree" ("professional_id");



CREATE INDEX "idx_notifications_read_status" ON "public"."notifications" USING "btree" ("read");



CREATE INDEX "idx_payments_job_id" ON "public"."payments" USING "btree" ("job_id");



CREATE INDEX "idx_payments_status" ON "public"."payments" USING "btree" ("status");



CREATE INDEX "idx_professionals_hourly_rate" ON "public"."professionals" USING "btree" ("hourly_rate");



CREATE INDEX "idx_professionals_is_available" ON "public"."professionals" USING "btree" ("is_available");



CREATE INDEX "idx_professionals_is_verified" ON "public"."professionals" USING "btree" ("is_verified");



CREATE INDEX "idx_professionals_license_number" ON "public"."professionals" USING "btree" ("license_number");



CREATE INDEX "idx_professionals_notification_preferences" ON "public"."professionals" USING "gin" ("notification_preferences");



CREATE INDEX "idx_professionals_payment_info" ON "public"."professionals" USING "gin" ("payment_info");



CREATE INDEX "idx_professionals_phone" ON "public"."professionals" USING "btree" ("phone");



CREATE INDEX "idx_professionals_profile_id" ON "public"."professionals" USING "btree" ("profile_id");



CREATE INDEX "idx_professionals_rating" ON "public"."professionals" USING "btree" ("rating");



CREATE INDEX "idx_professionals_services" ON "public"."professionals" USING "gin" ("services");



CREATE INDEX "idx_professionals_working_hours" ON "public"."professionals" USING "gin" ("working_hours");



CREATE INDEX "idx_professionals_years_of_experience" ON "public"."professionals" USING "btree" ("years_of_experience");



CREATE INDEX "idx_reschedule_requests_job_id" ON "public"."reschedule_requests" USING "btree" ("job_id");



CREATE INDEX "idx_reschedule_requests_original_date" ON "public"."reschedule_requests" USING "btree" ("original_date");



CREATE INDEX "idx_reschedule_requests_requested_by_id" ON "public"."reschedule_requests" USING "btree" ("requested_by_id");



CREATE INDEX "idx_reschedule_requests_status" ON "public"."reschedule_requests" USING "btree" ("status");



CREATE INDEX "idx_review_responses_review_id" ON "public"."review_responses" USING "btree" ("review_id");



CREATE INDEX "idx_reviews_job_id" ON "public"."reviews" USING "btree" ("job_id");



CREATE INDEX "idx_reviews_rating" ON "public"."reviews" USING "btree" ("rating");



CREATE INDEX "idx_reviews_reviewee_id" ON "public"."reviews" USING "btree" ("reviewee_id");



CREATE INDEX "idx_reviews_reviewer_id" ON "public"."reviews" USING "btree" ("reviewer_id");



CREATE INDEX "idx_schedule_slots_date" ON "public"."schedule_slots" USING "btree" ("date");



CREATE INDEX "idx_schedule_slots_job_id" ON "public"."schedule_slots" USING "btree" ("job_id");



CREATE INDEX "idx_schedule_slots_professional_id" ON "public"."schedule_slots" USING "btree" ("professional_id");



CREATE INDEX "idx_schedule_slots_status" ON "public"."schedule_slots" USING "btree" ("status");



CREATE INDEX "idx_working_hours_professional_id" ON "public"."working_hours" USING "btree" ("professional_id");



CREATE OR REPLACE TRIGGER "update_calendar_events_updated_at" BEFORE UPDATE ON "public"."calendar_events" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_calendar_syncs_updated_at" BEFORE UPDATE ON "public"."calendar_syncs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_direct_requests_updated_at" BEFORE UPDATE ON "public"."direct_requests" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_jobs_updated_at" BEFORE UPDATE ON "public"."jobs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_notifications_updated_at" BEFORE UPDATE ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_payments_updated_at" BEFORE UPDATE ON "public"."payments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_reschedule_requests_updated_at" BEFORE UPDATE ON "public"."reschedule_requests" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_review_responses_updated_at" BEFORE UPDATE ON "public"."review_responses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_reviews_updated_at" BEFORE UPDATE ON "public"."reviews" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_schedule_slots_updated_at" BEFORE UPDATE ON "public"."schedule_slots" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_working_hours_updated_at" BEFORE UPDATE ON "public"."working_hours" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."calendar_events"
    ADD CONSTRAINT "calendar_events_calendar_sync_id_fkey" FOREIGN KEY ("calendar_sync_id") REFERENCES "public"."calendar_syncs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."direct_requests"
    ADD CONSTRAINT "direct_requests_homeowner_id_fkey" FOREIGN KEY ("homeowner_id") REFERENCES "public"."homeowners"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."direct_requests"
    ADD CONSTRAINT "direct_requests_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reviews"
    ADD CONSTRAINT "fk_job" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_status_logs"
    ADD CONSTRAINT "fk_job" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."calendar_syncs"
    ADD CONSTRAINT "fk_profile" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."review_responses"
    ADD CONSTRAINT "fk_review" FOREIGN KEY ("review_id") REFERENCES "public"."reviews"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."homeowners"
    ADD CONSTRAINT "homeowners_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."job_status_logs"
    ADD CONSTRAINT "job_status_logs_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id");



ALTER TABLE ONLY "public"."job_status_logs"
    ADD CONSTRAINT "job_status_logs_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id");



ALTER TABLE ONLY "public"."job_status_logs"
    ADD CONSTRAINT "job_status_logs_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_homeowner_id_fkey" FOREIGN KEY ("homeowner_id") REFERENCES "public"."homeowners"("id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_payee_id_fkey" FOREIGN KEY ("payee_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."professionals"
    ADD CONSTRAINT "professionals_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."reschedule_requests"
    ADD CONSTRAINT "reschedule_requests_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."schedule_slots"
    ADD CONSTRAINT "schedule_slots_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."schedule_slots"
    ADD CONSTRAINT "schedule_slots_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."working_hours"
    ADD CONSTRAINT "working_hours_professional_id_fkey" FOREIGN KEY ("professional_id") REFERENCES "public"."professionals"("id") ON DELETE CASCADE;



CREATE POLICY "Enable admin verification" ON "public"."professionals" FOR UPDATE USING ((("auth"."jwt"() ->> 'role'::"text") = 'admin'::"text"));



CREATE POLICY "Enable insert for homeowners" ON "public"."direct_requests" FOR INSERT WITH CHECK (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "direct_requests"."homeowner_id"))));



CREATE POLICY "Enable insert for homeowners" ON "public"."jobs" FOR INSERT WITH CHECK ((( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "jobs"."homeowner_id")) = "auth"."uid"()));



CREATE POLICY "Enable insert for job participants" ON "public"."reschedule_requests" FOR INSERT WITH CHECK (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = ( SELECT "jobs"."homeowner_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id")))
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = ( SELECT "jobs"."professional_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id"))))));



CREATE POLICY "Enable insert for system" ON "public"."payments" FOR INSERT WITH CHECK (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Enable payment status update for involved parties" ON "public"."jobs" FOR UPDATE TO "authenticated" USING ((("auth"."uid"() = "homeowner_id") OR ("auth"."uid"() = "professional_id"))) WITH CHECK (((("auth"."uid"() = "homeowner_id") AND ("payment_status" = ANY (ARRAY['payment_pending'::"text", 'payment_processing'::"text"]))) OR (("auth"."uid"() = "professional_id") AND ("payment_status" = ANY (ARRAY['payment_completed'::"text", 'payment_failed'::"text"])))));



CREATE POLICY "Enable read access for all users" ON "public"."jobs" FOR SELECT USING (true);



CREATE POLICY "Enable read access for involved parties" ON "public"."direct_requests" FOR SELECT USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "direct_requests"."homeowner_id")
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "direct_requests"."professional_id"))));



CREATE POLICY "Enable read access for job participants" ON "public"."reschedule_requests" FOR SELECT USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = ( SELECT "jobs"."homeowner_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id")))
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = ( SELECT "jobs"."professional_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id"))))));



CREATE POLICY "Enable read access for payment participants" ON "public"."payments" FOR SELECT USING ((("payer_id" = "auth"."uid"()) OR ("payee_id" = "auth"."uid"())));



CREATE POLICY "Enable read access for verified professionals" ON "public"."professionals" FOR SELECT USING (((("auth"."jwt"() ->> 'role'::"text") = 'admin'::"text") OR ("auth"."uid"() = "profile_id") OR ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."user_type" = 'homeowner'::"text")))) AND ("is_verified" = true)) OR ("is_verified" = true)));



CREATE POLICY "Enable read access to all homeowners" ON "public"."homeowners" FOR SELECT USING (true);



CREATE POLICY "Enable read access to all jobs" ON "public"."jobs" FOR SELECT USING (true);



CREATE POLICY "Enable read access to all professionals" ON "public"."professionals" FOR SELECT USING (true);



CREATE POLICY "Enable read access to all profiles" ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Enable update for involved parties" ON "public"."direct_requests" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "direct_requests"."homeowner_id")
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "direct_requests"."professional_id"))));



CREATE POLICY "Enable update for job participants" ON "public"."jobs" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "jobs"."homeowner_id")
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "jobs"."professional_id")))) WITH CHECK (true);



CREATE POLICY "Enable update for job participants" ON "public"."reschedule_requests" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = ( SELECT "jobs"."homeowner_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id")))
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = ( SELECT "jobs"."professional_id"
           FROM "public"."jobs"
          WHERE ("jobs"."id" = "reschedule_requests"."job_id"))))));



CREATE POLICY "Enable update for own homeowner profile" ON "public"."homeowners" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Enable update for own jobs" ON "public"."jobs" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "jobs"."homeowner_id")
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "jobs"."professional_id")))) WITH CHECK (("auth"."uid"() IN ( SELECT "homeowners"."profile_id"
   FROM "public"."homeowners"
  WHERE ("homeowners"."id" = "jobs"."homeowner_id")
UNION
 SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "jobs"."professional_id"))));



CREATE POLICY "Enable update for own professional profile" ON "public"."professionals" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK (("auth"."uid"() = "profile_id"));



CREATE POLICY "Enable update for own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Enable update for system" ON "public"."payments" FOR UPDATE USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Enable verification status update for professionals" ON "public"."jobs" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "professional_id")) WITH CHECK (("verification_status" = ANY (ARRAY['verification_pending'::"text", 'verification_approved'::"text", 'verification_rejected'::"text"])));



CREATE POLICY "Professionals can manage their own slots" ON "public"."schedule_slots" USING (("professional_id" = "auth"."uid"())) WITH CHECK (("professional_id" = "auth"."uid"()));



CREATE POLICY "Professionals can manage their own working hours" ON "public"."working_hours" USING (("professional_id" = "auth"."uid"())) WITH CHECK (("professional_id" = "auth"."uid"()));



CREATE POLICY "Professionals can update their own notifications" ON "public"."notifications" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "notifications"."professional_id")))) WITH CHECK (("auth"."uid"() IN ( SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "notifications"."professional_id"))));



CREATE POLICY "Professionals can view their own notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() IN ( SELECT "professionals"."profile_id"
   FROM "public"."professionals"
  WHERE ("professionals"."id" = "notifications"."professional_id"))));



CREATE POLICY "Read verified professionals" ON "public"."professionals" FOR SELECT USING ((("is_verified" = true) OR ("auth"."uid"() = "profile_id")));



CREATE POLICY "System can create notifications" ON "public"."notifications" FOR INSERT WITH CHECK (true);



CREATE POLICY "Update own profile" ON "public"."professionals" FOR UPDATE USING (("auth"."uid"() = "profile_id")) WITH CHECK ((("auth"."uid"() = "profile_id") AND (NOT ("is_verified" IS DISTINCT FROM "is_verified"))));



CREATE POLICY "Users can create responses to reviews about them" ON "public"."review_responses" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."reviews"
  WHERE (("reviews"."id" = "review_responses"."review_id") AND ("reviews"."reviewee_id" = "auth"."uid"())))));



CREATE POLICY "Users can create reviews for their jobs" ON "public"."reviews" FOR INSERT WITH CHECK ((("reviewer_id" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."jobs"
  WHERE (("jobs"."id" = "reviews"."job_id") AND (((("reviews"."reviewer_type")::"text" = 'HOMEOWNER'::"text") AND ("jobs"."homeowner_id" = "reviews"."reviewer_id")) OR ((("reviews"."reviewer_type")::"text" = 'PROFESSIONAL'::"text") AND ("jobs"."professional_id" = "reviews"."reviewer_id"))))))));



CREATE POLICY "Users can delete their own responses" ON "public"."review_responses" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."reviews"
  WHERE (("reviews"."id" = "review_responses"."review_id") AND ("reviews"."reviewee_id" = "auth"."uid"())))));



CREATE POLICY "Users can delete their own reviews" ON "public"."reviews" FOR DELETE USING (("reviewer_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their own calendar events" ON "public"."calendar_events" USING (("calendar_sync_id" IN ( SELECT "calendar_syncs"."id"
   FROM "public"."calendar_syncs"
  WHERE ("calendar_syncs"."profile_id" = "auth"."uid"())))) WITH CHECK (("calendar_sync_id" IN ( SELECT "calendar_syncs"."id"
   FROM "public"."calendar_syncs"
  WHERE ("calendar_syncs"."profile_id" = "auth"."uid"()))));



CREATE POLICY "Users can manage their own calendar syncs" ON "public"."calendar_syncs" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));



CREATE POLICY "Users can update their own responses" ON "public"."review_responses" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."reviews"
  WHERE (("reviews"."id" = "review_responses"."review_id") AND ("reviews"."reviewee_id" = "auth"."uid"())))));



CREATE POLICY "Users can update their own reviews" ON "public"."reviews" FOR UPDATE USING (("reviewer_id" = "auth"."uid"()));



CREATE POLICY "Users can view all review responses" ON "public"."review_responses" FOR SELECT USING (true);



CREATE POLICY "Users can view all reviews" ON "public"."reviews" FOR SELECT USING (true);



CREATE POLICY "Users can view all schedule slots" ON "public"."schedule_slots" FOR SELECT USING (true);



CREATE POLICY "Users can view all working hours" ON "public"."working_hours" FOR SELECT USING (true);



CREATE POLICY "Users can view their own calendar events" ON "public"."calendar_events" FOR SELECT USING (("calendar_sync_id" IN ( SELECT "calendar_syncs"."id"
   FROM "public"."calendar_syncs"
  WHERE ("calendar_syncs"."profile_id" = "auth"."uid"()))));



CREATE POLICY "Users can view their own calendar syncs" ON "public"."calendar_syncs" FOR SELECT USING (("profile_id" = "auth"."uid"()));



ALTER TABLE "public"."calendar_events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."calendar_syncs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."direct_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."professionals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reschedule_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."review_responses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."schedule_slots" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."working_hours" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


























































































































































































GRANT ALL ON FUNCTION "public"."check_review_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_review_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_review_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_slot_availability"("p_professional_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."check_slot_availability"("p_professional_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_slot_availability"("p_professional_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."count_pending_jobs"("professional_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."count_pending_jobs"("professional_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_pending_jobs"("professional_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."count_today_jobs"("professional_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."count_today_jobs"("professional_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_today_jobs"("professional_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."count_unread_notifications"("profile_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."count_unread_notifications"("profile_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_unread_notifications"("profile_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_booking"("p_professional_id" "uuid", "p_homeowner_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone, "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_booking"("p_professional_id" "uuid", "p_homeowner_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone, "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_booking"("p_professional_id" "uuid", "p_homeowner_id" "uuid", "p_date" "date", "p_start_time" time without time zone, "p_end_time" time without time zone, "p_description" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_table_info"("table_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_table_info"("table_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_table_info"("table_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_job_status"("job_id" "uuid", "new_status" "text", "professional_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_job_status"("job_id" "uuid", "new_status" "text", "professional_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_job_status"("job_id" "uuid", "new_status" "text", "professional_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."calendar_events" TO "anon";
GRANT ALL ON TABLE "public"."calendar_events" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_events" TO "service_role";



GRANT ALL ON TABLE "public"."calendar_syncs" TO "anon";
GRANT ALL ON TABLE "public"."calendar_syncs" TO "authenticated";
GRANT ALL ON TABLE "public"."calendar_syncs" TO "service_role";



GRANT ALL ON TABLE "public"."direct_requests" TO "anon";
GRANT ALL ON TABLE "public"."direct_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."direct_requests" TO "service_role";



GRANT ALL ON TABLE "public"."homeowners" TO "anon";
GRANT ALL ON TABLE "public"."homeowners" TO "authenticated";
GRANT ALL ON TABLE "public"."homeowners" TO "service_role";



GRANT ALL ON TABLE "public"."job_status_logs" TO "anon";
GRANT ALL ON TABLE "public"."job_status_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."job_status_logs" TO "service_role";



GRANT ALL ON TABLE "public"."jobs" TO "anon";
GRANT ALL ON TABLE "public"."jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."jobs" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON TABLE "public"."professionals" TO "anon";
GRANT ALL ON TABLE "public"."professionals" TO "authenticated";
GRANT ALL ON TABLE "public"."professionals" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."reschedule_requests" TO "anon";
GRANT ALL ON TABLE "public"."reschedule_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."reschedule_requests" TO "service_role";



GRANT ALL ON TABLE "public"."review_responses" TO "anon";
GRANT ALL ON TABLE "public"."review_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."review_responses" TO "service_role";



GRANT ALL ON TABLE "public"."reviews" TO "anon";
GRANT ALL ON TABLE "public"."reviews" TO "authenticated";
GRANT ALL ON TABLE "public"."reviews" TO "service_role";



GRANT ALL ON TABLE "public"."schedule_slots" TO "anon";
GRANT ALL ON TABLE "public"."schedule_slots" TO "authenticated";
GRANT ALL ON TABLE "public"."schedule_slots" TO "service_role";



GRANT ALL ON TABLE "public"."working_hours" TO "anon";
GRANT ALL ON TABLE "public"."working_hours" TO "authenticated";
GRANT ALL ON TABLE "public"."working_hours" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;

-- Update job status constants
CREATE TYPE job_status AS ENUM (
  'awaiting_acceptance',
  'scheduled',
  'started',
  'completed',
  'cancelled'
);

-- Update job payment status constants
CREATE TYPE job_payment_status AS ENUM (
  'payment_pending',
  'payment_processing',
  'payment_completed',
  'payment_failed',
  'payment_refunded'
);

-- Update job verification status constants
CREATE TYPE job_verification_status AS ENUM (
  'verification_pending',
  'verification_approved',
  'verification_rejected'
);

-- Update jobs table to use the new types
ALTER TABLE jobs
  ALTER COLUMN status TYPE job_status USING status::job_status,
  ALTER COLUMN payment_status TYPE job_payment_status USING payment_status::job_payment_status,
  ALTER COLUMN verification_status TYPE job_verification_status USING verification_status::job_verification_status;

-- Update the query to use the correct status
AND jobs.status = 'awaiting_acceptance';
