-- ClinixAI Database Initialization Script
-- This runs automatically when PostgreSQL container starts

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== USERS TABLE ====================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) UNIQUE,
    email VARCHAR(255),
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    blood_type VARCHAR(5),
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    consent_given BOOLEAN DEFAULT FALSE,
    consent_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== TRIAGE SESSIONS TABLE ====================
CREATE TABLE IF NOT EXISTS triage_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    session_end TIMESTAMPTZ,
    processing_mode VARCHAR(20) NOT NULL DEFAULT 'local',
    device_id VARCHAR(255),
    device_model VARCHAR(100),
    app_version VARCHAR(20),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== SYMPTOMS TABLE ====================
CREATE TABLE IF NOT EXISTS symptoms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES triage_sessions(id) ON DELETE CASCADE,
    symptom_code VARCHAR(20),
    symptom_description TEXT NOT NULL,
    severity INT CHECK (severity BETWEEN 1 AND 10),
    duration_hours INT,
    body_location VARCHAR(100),
    image_url TEXT,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== TRIAGE RESULTS TABLE ====================
CREATE TABLE IF NOT EXISTS triage_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES triage_sessions(id) ON DELETE CASCADE,
    urgency_level VARCHAR(20) NOT NULL,
    confidence_score DECIMAL(5, 4),
    ai_model_version VARCHAR(50),
    primary_assessment TEXT,
    recommended_action TEXT,
    differential_diagnoses JSONB,
    follow_up_required BOOLEAN DEFAULT FALSE,
    escalated_to_cloud BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== EHR SYNC LOG TABLE ====================
CREATE TABLE IF NOT EXISTS ehr_sync_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES triage_sessions(id) ON DELETE CASCADE,
    target_system VARCHAR(50),
    fhir_resource_type VARCHAR(50),
    fhir_resource_id VARCHAR(255),
    sync_status VARCHAR(20) DEFAULT 'pending',
    sync_timestamp TIMESTAMPTZ,
    error_message TEXT,
    retry_count INT DEFAULT 0
);

-- ==================== HEALTHCARE PROVIDERS TABLE ====================
CREATE TABLE IF NOT EXISTS healthcare_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    facility_name VARCHAR(255) NOT NULL,
    facility_type VARCHAR(50),
    license_number VARCHAR(100),
    address TEXT,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    ehr_system VARCHAR(50),
    ehr_api_endpoint TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== PROVIDER STAFF TABLE ====================
CREATE TABLE IF NOT EXISTS provider_staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES healthcare_providers(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50),
    license_number VARCHAR(100),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    password_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== API KEYS TABLE ====================
CREATE TABLE IF NOT EXISTS api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES healthcare_providers(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    permissions JSONB DEFAULT '["read"]',
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== AUDIT LOG TABLE ====================
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    staff_id UUID,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== INDEXES ====================
CREATE INDEX IF NOT EXISTS idx_triage_sessions_user ON triage_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_triage_sessions_start ON triage_sessions(session_start DESC);
CREATE INDEX IF NOT EXISTS idx_symptoms_session ON symptoms(session_id);
CREATE INDEX IF NOT EXISTS idx_triage_results_session ON triage_results(session_id);
CREATE INDEX IF NOT EXISTS idx_triage_results_urgency ON triage_results(urgency_level);
CREATE INDEX IF NOT EXISTS idx_ehr_sync_status ON ehr_sync_log(sync_status);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON audit_log(created_at DESC);

-- ==================== TRIGGERS ====================
-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==================== SEED DATA (Development Only) ====================
-- Insert a test healthcare provider
INSERT INTO healthcare_providers (facility_name, facility_type, address, ehr_system, is_active)
VALUES ('ClinixAI Test Hospital', 'hospital', 'Lagos, Nigeria', 'openmrs', TRUE)
ON CONFLICT DO NOTHING;

COMMENT ON TABLE users IS 'Patient profiles synced from mobile app';
COMMENT ON TABLE triage_sessions IS 'Each triage interaction from mobile app';
COMMENT ON TABLE symptoms IS 'Individual symptoms per triage session';
COMMENT ON TABLE triage_results IS 'AI-generated triage assessments';
COMMENT ON TABLE ehr_sync_log IS 'Track syncs to external EHR systems';
