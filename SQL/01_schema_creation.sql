-- Create schemas
CREATE SCHEMA IF NOT EXISTS raw_olist;
CREATE SCHEMA IF NOT EXISTS cleaned;
CREATE SCHEMA IF NOT EXISTS analytics;

COMMENT ON SCHEMA raw_olist IS 'Raw data as loaded from CSVs';
COMMENT ON SCHEMA cleaned IS 'Cleaned and transformed tables';
COMMENT ON SCHEMA analytics IS 'Views and materialized views for analysis';