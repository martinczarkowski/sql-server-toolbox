/*
Purpose:
  Shows metadata for the current database, including size, files, compatibility level and selected options.

Notes:
  - Read-only.
  - Run this script in the database you want to inspect.
  - Useful before deployments, migrations and performance troubleshooting.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

DECLARE @database_name sysname = DB_NAME();

SELECT
    d.name AS database_name,
    d.database_id,
    d.create_date,
    d.compatibility_level,
    d.collation_name,
    d.recovery_model_desc,
    d.state_desc,
    d.user_access_desc,
    d.is_read_only,
    d.is_auto_close_on,
    d.is_auto_shrink_on,
    d.is_auto_create_stats_on,
    d.is_auto_update_stats_on,
    d.is_auto_update_stats_async_on,
    d.page_verify_option_desc,
    d.snapshot_isolation_state_desc,
    d.is_read_committed_snapshot_on,
    d.target_recovery_time_in_seconds,
    SUSER_SNAME(d.owner_sid) AS owner_name
FROM sys.databases AS d
WHERE d.name = @database_name;

SELECT
    mf.name AS logical_file_name,
    mf.type_desc,
    mf.physical_name,
    CAST(mf.size * 8.0 / 1024 AS decimal(18, 2)) AS size_mb,
    CASE mf.max_size
        WHEN -1 THEN NULL
        ELSE CAST(mf.max_size * 8.0 / 1024 AS decimal(18, 2))
    END AS max_size_mb,
    CASE mf.is_percent_growth
        WHEN 1 THEN CONCAT(mf.growth, ' %')
        ELSE CONCAT(CAST(mf.growth * 8.0 / 1024 AS decimal(18, 2)), ' MB')
    END AS growth_setting,
    mf.state_desc
FROM sys.master_files AS mf
WHERE mf.database_id = DB_ID()
ORDER BY mf.type_desc, mf.file_id;

SELECT
    SUM(CASE WHEN mf.type_desc = 'ROWS' THEN mf.size ELSE 0 END) * 8.0 / 1024 AS data_size_mb,
    SUM(CASE WHEN mf.type_desc = 'LOG' THEN mf.size ELSE 0 END) * 8.0 / 1024 AS log_size_mb,
    SUM(mf.size) * 8.0 / 1024 AS total_size_mb
FROM sys.master_files AS mf
WHERE mf.database_id = DB_ID();

SELECT
    s.name AS schema_name,
    COUNT(t.object_id) AS table_count
FROM sys.schemas AS s
LEFT JOIN sys.tables AS t
    ON t.schema_id = s.schema_id
    AND t.is_ms_shipped = 0
GROUP BY s.name
HAVING COUNT(t.object_id) > 0
ORDER BY table_count DESC, s.name;

SELECT
    COUNT(*) AS user_tables
FROM sys.tables
WHERE is_ms_shipped = 0;

SELECT
    COUNT(*) AS user_views
FROM sys.views
WHERE is_ms_shipped = 0;

SELECT
    COUNT(*) AS stored_procedures
FROM sys.procedures
WHERE is_ms_shipped = 0;