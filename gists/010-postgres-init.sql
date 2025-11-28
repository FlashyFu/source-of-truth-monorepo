-- ============================================================================
-- 010-postgres-init.sql
-- Secure PostgreSQL initialization script with roles, schemas, and guidance
-- ============================================================================
--
-- HOW TO USE:
--   1. Customize role names, passwords, and schema names
--   2. Run against a fresh database: psql -U postgres -f postgres-init.sql
--   3. Or use with Docker: mount as /docker-entrypoint-initdb.d/init.sql
--
-- SECURITY NOTES:
--   - Never commit real passwords - use environment variables
--   - Principle of least privilege - grant only necessary permissions
--   - Use separate roles for different access levels
--
-- ============================================================================

-- ============================================================================
-- 1. Create Roles
-- ============================================================================

-- Application role (read/write for app operations)
CREATE ROLE app_user WITH
    LOGIN
    PASSWORD 'CHANGE_ME_app_password_here'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    CONNECTION LIMIT 50;

COMMENT ON ROLE app_user IS 'Application database user with read/write access';

-- Read-only role (for reporting, analytics)
CREATE ROLE readonly_user WITH
    LOGIN
    PASSWORD 'CHANGE_ME_readonly_password_here'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    CONNECTION LIMIT 10;

COMMENT ON ROLE readonly_user IS 'Read-only access for reporting';

-- Migration role (for running migrations)
CREATE ROLE migrations_user WITH
    LOGIN
    PASSWORD 'CHANGE_ME_migrations_password_here'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    CONNECTION LIMIT 5;

COMMENT ON ROLE migrations_user IS 'Database migrations user with DDL access';

-- ============================================================================
-- 2. Create Database (run as superuser)
-- ============================================================================

-- Note: Create database separately if needed
-- CREATE DATABASE myapp_db
--     WITH OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.utf8'
--     LC_CTYPE = 'en_US.utf8'
--     TEMPLATE = template0;

-- Connect to the application database
\c myapp_db

-- ============================================================================
-- 3. Create Extensions
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";       -- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS "citext";         -- Case-insensitive text

-- ============================================================================
-- 4. Create Schemas
-- ============================================================================

-- Application schema
CREATE SCHEMA IF NOT EXISTS app;
COMMENT ON SCHEMA app IS 'Main application schema';

-- Audit schema for tracking changes
CREATE SCHEMA IF NOT EXISTS audit;
COMMENT ON SCHEMA audit IS 'Audit logging schema';

-- Set search path
ALTER DATABASE myapp_db SET search_path TO app, public;

-- ============================================================================
-- 5. Create Tables
-- ============================================================================

-- Users table
CREATE TABLE app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email CITEXT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON app.users(email);
CREATE INDEX idx_users_created_at ON app.users(created_at);

COMMENT ON TABLE app.users IS 'User accounts';
COMMENT ON COLUMN app.users.password_hash IS 'bcrypt hashed password';

-- Sessions table (for session-based auth)
CREATE TABLE app.sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON app.sessions(user_id);
CREATE INDEX idx_sessions_expires_at ON app.sessions(expires_at);

-- Audit log table
CREATE TABLE audit.activity_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    ip_address INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_log_table_record ON audit.activity_log(table_name, record_id);
CREATE INDEX idx_activity_log_created_at ON audit.activity_log(created_at);

-- ============================================================================
-- 6. Create Functions
-- ============================================================================

-- Automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION app.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION app.update_updated_at_column();

-- Audit logging function
CREATE OR REPLACE FUNCTION audit.log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit.activity_log (table_name, record_id, action, old_data)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, to_jsonb(OLD));
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.activity_log (table_name, record_id, action, old_data, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit.activity_log (table_name, record_id, action, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, to_jsonb(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Apply audit trigger to users table
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION audit.log_changes();

-- ============================================================================
-- 7. Grant Permissions
-- ============================================================================

-- App user permissions
GRANT USAGE ON SCHEMA app TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT USAGE, SELECT ON SEQUENCES TO app_user;

-- Read-only user permissions
GRANT USAGE ON SCHEMA app TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO readonly_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT ON TABLES TO readonly_user;

-- Migrations user permissions
GRANT ALL ON SCHEMA app TO migrations_user;
GRANT ALL ON ALL TABLES IN SCHEMA app TO migrations_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA app TO migrations_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT ALL ON TABLES TO migrations_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT ALL ON SEQUENCES TO migrations_user;

-- ============================================================================
-- 8. Create Maintenance Jobs (for pg_cron if installed)
-- ============================================================================

-- Note: Uncomment if pg_cron is installed
-- -- Clean up expired sessions daily
-- SELECT cron.schedule('cleanup-expired-sessions', '0 3 * * *',
--     $$DELETE FROM app.sessions WHERE expires_at < NOW()$$
-- );
-- 
-- -- Vacuum analyze weekly
-- SELECT cron.schedule('vacuum-analyze', '0 4 * * 0',
--     $$VACUUM ANALYZE$$
-- );

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- List all roles
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolconnlimit 
FROM pg_roles 
WHERE rolname IN ('app_user', 'readonly_user', 'migrations_user');

-- List all schemas
SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name IN ('app', 'audit');

-- List all tables
SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE schemaname IN ('app', 'audit');

-- ============================================================================
-- PRODUCTION CHECKLIST:
-- - [ ] Replace all CHANGE_ME passwords with secure, generated passwords
-- - [ ] Store passwords in secrets manager (Vault, AWS Secrets Manager)
-- - [ ] Enable SSL connections (ssl = on in postgresql.conf)
-- - [ ] Configure pg_hba.conf for proper authentication
-- - [ ] Set up automated backups (pg_dump, WAL archiving)
-- - [ ] Configure connection pooling (PgBouncer)
-- - [ ] Set appropriate connection limits per role
-- - [ ] Enable query logging for debugging (log_statement)
-- - [ ] Set up monitoring (pg_stat_statements, pgMonitor)
-- - [ ] Test disaster recovery procedures
-- ============================================================================
