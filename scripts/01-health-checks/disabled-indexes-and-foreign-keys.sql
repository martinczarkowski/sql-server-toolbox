/*
Purpose:
  Lists disabled indexes and disabled foreign keys in the current database.

Notes:
  - Read-only.
  - Disabled indexes and constraints are easy to forget after bulk loads, migrations or failed maintenance.
  - Review results before enabling anything. A disabled object can be intentional.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

SELECT
    'DISABLED_INDEX' AS issue_type,
    s.name AS schema_name,
    t.name AS table_name,
    i.name AS object_name,
    i.type_desc AS object_type,
    i.is_primary_key,
    i.is_unique,
    i.is_unique_constraint,
    p.rows AS row_count
FROM sys.indexes AS i
INNER JOIN sys.tables AS t
    ON t.object_id = i.object_id
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
LEFT JOIN sys.partitions AS p
    ON p.object_id = i.object_id
    AND p.index_id IN (0, 1)
WHERE i.is_disabled = 1
  AND t.is_ms_shipped = 0
ORDER BY s.name, t.name, i.name;

SELECT
    'DISABLED_FOREIGN_KEY' AS issue_type,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS schema_name,
    OBJECT_NAME(fk.parent_object_id) AS table_name,
    fk.name AS object_name,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS referenced_schema_name,
    OBJECT_NAME(fk.referenced_object_id) AS referenced_table_name,
    fk.is_disabled,
    fk.is_not_trusted,
    fk.delete_referential_action_desc,
    fk.update_referential_action_desc
FROM sys.foreign_keys AS fk
WHERE fk.is_disabled = 1
ORDER BY schema_name, table_name, fk.name;

SELECT
    disabled_indexes =
    (
        SELECT COUNT(*)
        FROM sys.indexes AS i
        INNER JOIN sys.tables AS t
            ON t.object_id = i.object_id
        WHERE i.is_disabled = 1
          AND t.is_ms_shipped = 0
    ),
    disabled_foreign_keys =
    (
        SELECT COUNT(*)
        FROM sys.foreign_keys AS fk
        WHERE fk.is_disabled = 1
    );