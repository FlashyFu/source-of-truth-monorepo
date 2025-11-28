-- ============================================================================
-- 011-sql-migration-template.sql
-- SQL Migration Template with Up/Down scripts and instructions
-- ============================================================================
--
-- HOW TO USE:
--   1. Copy this file for each migration: YYYYMMDD_HHMMSS_description.sql
--   2. Implement both UP and DOWN sections
--   3. Test in development first: psql -f migration.sql
--   4. Apply with your migration tool or manually
--
-- NAMING CONVENTION:
--   20240115_093000_add_users_email_index.sql
--   20240116_140000_create_orders_table.sql
--   20240117_101500_alter_users_add_phone.sql
--
-- MIGRATION TOOLS:
--   - Node.js: node-pg-migrate, knex, prisma
--   - Python: alembic, django migrations
--   - Go: goose, golang-migrate
--   - Generic: flyway, liquibase
--
-- ============================================================================

-- ============================================================================
-- MIGRATION METADATA
-- ============================================================================
-- Migration ID: 20240115_093000
-- Description: Add email index to users table
-- Author: Your Name
-- Date: 2024-01-15
-- Ticket: PROJ-123
-- ============================================================================

-- ============================================================================
-- UP MIGRATION - Apply changes
-- ============================================================================

BEGIN;

-- Add your schema changes here

-- Example 1: Create a new table
-- CREATE TABLE IF NOT EXISTS app.orders (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
--     status VARCHAR(50) NOT NULL DEFAULT 'pending',
--     total_amount DECIMAL(10, 2) NOT NULL,
--     currency VARCHAR(3) NOT NULL DEFAULT 'USD',
--     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- Example 2: Add a column
-- ALTER TABLE app.users
--     ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

-- Example 3: Add an index
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email_lower
    ON app.users (lower(email));

-- Example 4: Add a constraint
-- ALTER TABLE app.orders
--     ADD CONSTRAINT chk_positive_amount
--     CHECK (total_amount >= 0);

-- Example 5: Create a function
-- CREATE OR REPLACE FUNCTION app.calculate_order_total(order_id UUID)
-- RETURNS DECIMAL AS $$
-- DECLARE
--     total DECIMAL;
-- BEGIN
--     SELECT SUM(quantity * unit_price)
--     INTO total
--     FROM app.order_items
--     WHERE order_id = calculate_order_total.order_id;
--     
--     RETURN COALESCE(total, 0);
-- END;
-- $$ LANGUAGE plpgsql;

-- Record migration (if using custom tracking)
-- INSERT INTO schema_migrations (version, description, applied_at)
-- VALUES ('20240115_093000', 'Add email index to users table', NOW());

COMMIT;

-- ============================================================================
-- DOWN MIGRATION - Rollback changes
-- ============================================================================
-- NOTE: Keep this section for reference but comment it out.
--       Run manually if rollback is needed.
-- ============================================================================

-- BEGIN;

-- Reverse the changes in opposite order

-- Example 1: Drop table
-- DROP TABLE IF EXISTS app.orders CASCADE;

-- Example 2: Drop column
-- ALTER TABLE app.users
--     DROP COLUMN IF EXISTS phone;

-- Example 3: Drop index
-- DROP INDEX CONCURRENTLY IF EXISTS app.idx_users_email_lower;

-- Example 4: Drop constraint
-- ALTER TABLE app.orders
--     DROP CONSTRAINT IF EXISTS chk_positive_amount;

-- Example 5: Drop function
-- DROP FUNCTION IF EXISTS app.calculate_order_total(UUID);

-- Remove migration record
-- DELETE FROM schema_migrations WHERE version = '20240115_093000';

-- COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if index was created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'users' AND indexname = 'idx_users_email_lower';

-- Check table structure
-- \d app.users

-- Check constraints
-- SELECT conname, contype, pg_get_constraintdef(oid)
-- FROM pg_constraint
-- WHERE conrelid = 'app.orders'::regclass;

-- ============================================================================
-- MIGRATION BEST PRACTICES
-- ============================================================================
--
-- 1. ATOMICITY
--    - Wrap migrations in transactions when possible
--    - Use BEGIN/COMMIT for transactional DDL
--    - Note: CREATE INDEX CONCURRENTLY cannot run in a transaction
--
-- 2. BACKWARD COMPATIBILITY
--    - Add columns as nullable first, then add NOT NULL in a later migration
--    - Use default values for new required columns
--    - Keep old columns during transition period (deprecation phase)
--
-- 3. PERFORMANCE
--    - Use CONCURRENTLY for index operations on large tables
--    - Batch large data updates to avoid long locks
--    - Consider running during low-traffic periods
--
-- 4. SAFETY
--    - Always test in staging/development first
--    - Have a rollback plan (DOWN migration)
--    - Take backups before running on production
--    - Use SELECT ... FOR UPDATE for critical data changes
--
-- 5. DOCUMENTATION
--    - Document the reason for each change
--    - Reference tickets/issues
--    - Note any manual steps required
--
-- ============================================================================
-- MIGRATION TRACKING TABLE (if not using a migration tool)
-- ============================================================================

-- CREATE TABLE IF NOT EXISTS schema_migrations (
--     id SERIAL PRIMARY KEY,
--     version VARCHAR(50) NOT NULL UNIQUE,
--     description TEXT,
--     applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     applied_by VARCHAR(100) DEFAULT current_user
-- );
--
-- CREATE INDEX idx_migrations_version ON schema_migrations(version);

-- ============================================================================
-- DATA MIGRATION TEMPLATE
-- ============================================================================

-- For data migrations, use a separate file and follow this pattern:

-- BEGIN;
-- 
-- -- Create temporary table/backup
-- CREATE TABLE app.users_backup AS SELECT * FROM app.users;
-- 
-- -- Perform data transformation
-- UPDATE app.users
-- SET email = lower(email)
-- WHERE email != lower(email);
-- 
-- -- Verify results
-- SELECT COUNT(*) as updated_count
-- FROM app.users
-- WHERE email = lower(email);
-- 
-- -- If verification passes, commit
-- COMMIT;
-- 
-- -- Clean up backup after verification (in a separate script)
-- -- DROP TABLE app.users_backup;

-- ============================================================================
