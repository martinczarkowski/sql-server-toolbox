/*
Purpose:
  Demonstrates a safer dynamic SQL pattern using sys.sp_executesql and parameters.

Notes:
  - Template only.
  - Parameterize values. Do not concatenate user input into SQL text.
  - Object names cannot be parameterized, so validate and wrap them with QUOTENAME.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

DECLARE @schema_name sysname = N'dbo';
DECLARE @table_name sysname = N'ExampleTable';
DECLARE @status int = 1;
DECLARE @created_from datetime2(0) = DATEADD(day, -7, SYSDATETIME());

IF NOT EXISTS
(
    SELECT 1
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
        ON s.schema_id = t.schema_id
    WHERE s.name = @schema_name
      AND t.name = @table_name
)
BEGIN
    THROW 50000, 'The requested table does not exist.', 1;
END;

DECLARE @sql nvarchar(max) =
    N'SELECT COUNT_BIG(*) AS row_count
      FROM ' + QUOTENAME(@schema_name) + N'.' + QUOTENAME(@table_name) + N'
      WHERE Status = @status
        AND CreatedAt >= @created_from;';

DECLARE @parameters nvarchar(max) =
    N'@status int,
      @created_from datetime2(0)';

EXEC sys.sp_executesql
    @stmt = @sql,
    @params = @parameters,
    @status = @status,
    @created_from = @created_from;