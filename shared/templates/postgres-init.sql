-- Database initialization: create roles, database, schema and example user with minimal privileges.
-- Run as postgres superuser: psql -f postgres-init.sql

-- Replace names/values before running
CREATE ROLE app_role NOINHERIT LOGIN PASSWORD 'replace_with_strong_password';
CREATE DATABASE app_db OWNER app_role;

\c app_db

-- Create schema for application separation
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION app_role;

-- Example table
CREATE TABLE app.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  hashed_password TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Grant only necessary privileges to role
GRANT USAGE ON SCHEMA app TO app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_role;

-- Notes:
-- - Use pgcrypto extension for gen_random_uuid() if available
-- - Store migration history in a dedicated table (e.g. alembic_version)
