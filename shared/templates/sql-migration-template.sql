-- Migration: add a new column to users table
-- Filename convention: 20251128_add_user_profile.sql
-- Use the "up" section to apply and "down" to rollback if supported by your migration tool.

-- UP
BEGIN;

ALTER TABLE app.users
  ADD COLUMN bio TEXT;

-- Populate defaults or migrate data if needed
-- UPDATE app.users SET bio = '' WHERE bio IS NULL;

COMMIT;

-- DOWN
-- To rollback, provide reverse changes (if using manual rollback)
-- BEGIN;
-- ALTER TABLE app.users DROP COLUMN IF EXISTS bio;
-- COMMIT;

-- Notes:
-- - When writing migrations for production, make them backward compatible when possible:
--   1) Add nullable column
--   2) Deploy code that writes/reads column
--   3) Backfill data
--   4) Make column NOT NULL if required
