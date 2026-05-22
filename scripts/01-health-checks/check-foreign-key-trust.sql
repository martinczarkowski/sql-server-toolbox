/*
Purpose:
  Lists foreign keys that are enabled but not trusted by SQL Server.

Notes:
  - Read-only.
  - An untrusted foreign key may not be used by the optimizer for query simplification.
  - This commonly happens after using WITH NOCHECK during imports, migrations or emergency fixes.
  - Do not blindly run WITH CHECK CHECK CONSTRAINT in production. Validate the data first.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

SELECT
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS schema_name,
    OBJECT_NAME(fk.parent_object_id) AS table_name,
    fk.name AS foreign_key_name,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS referenced_schema_name,
    OBJECT_NAME(fk.referenced_object_id) AS referenced_table_name,
    fk.is_disabled,
    fk.is_not_trusted,
    fk.delete_referential_action_desc,
    fk.update_referential_action_desc,
    'ALTER TABLE '
        + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id))
        + '.'
        + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
        + ' WITH CHECK CHECK CONSTRAINT '
        + QUOTENAME(fk.name)
        + ';' AS suggested_retrust_command
FROM sys.foreign_keys AS fk
WHERE fk.is_not_trusted = 1
  AND fk.is_disabled = 0
ORDER BY schema_name, table_name, fk.name;

SELECT
    untrusted_enabled_foreign_keys = COUNT(*)
FROM sys.foreign_keys AS fk
WHERE fk.is_not_trusted = 1
  AND fk.is_disabled = 0;