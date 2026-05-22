/*
Purpose:
  Shows row counts and size information for user tables in the current database.

Notes:
  - Read-only.
  - Row counts are based on partition metadata and are usually fast to read.
  - Useful before migrations, cleanup work and performance investigations.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

WITH table_size AS
(
    SELECT
        s.name AS schema_name,
        t.name AS table_name,
        SUM(p.rows) AS row_count,
        SUM(a.total_pages) * 8.0 / 1024 AS total_mb,
        SUM(a.used_pages) * 8.0 / 1024 AS used_mb,
        (SUM(a.total_pages) - SUM(a.used_pages)) * 8.0 / 1024 AS unused_mb,
        SUM(CASE WHEN i.index_id IN (0, 1) THEN a.used_pages ELSE 0 END) * 8.0 / 1024 AS data_mb,
        SUM(CASE WHEN i.index_id > 1 THEN a.used_pages ELSE 0 END) * 8.0 / 1024 AS index_mb
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
        ON s.schema_id = t.schema_id
    INNER JOIN sys.indexes AS i
        ON i.object_id = t.object_id
    INNER JOIN sys.partitions AS p
        ON p.object_id = i.object_id
        AND p.index_id = i.index_id
    INNER JOIN sys.allocation_units AS a
        ON a.container_id = p.partition_id
    WHERE t.is_ms_shipped = 0
    GROUP BY s.name, t.name
)
SELECT
    schema_name,
    table_name,
    row_count,
    CAST(total_mb AS decimal(18, 2)) AS total_mb,
    CAST(used_mb AS decimal(18, 2)) AS used_mb,
    CAST(unused_mb AS decimal(18, 2)) AS unused_mb,
    CAST(data_mb AS decimal(18, 2)) AS data_mb,
    CAST(index_mb AS decimal(18, 2)) AS index_mb
FROM table_size
ORDER BY total_mb DESC, row_count DESC, schema_name, table_name;