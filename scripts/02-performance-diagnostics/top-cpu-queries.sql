/*
Purpose:
  Shows cached queries with the highest total CPU usage.

Notes:
  - Read-only.
  - Results come from the plan cache. They reset after SQL Server restart, database detach, memory pressure or plan eviction.
  - High total CPU does not automatically mean bad SQL. Use this as an investigation starting point.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

SELECT TOP (50)
    DB_NAME(st.dbid) AS database_name,
    qs.execution_count,
    CAST(qs.total_worker_time / 1000.0 AS decimal(18, 2)) AS total_cpu_ms,
    CAST(qs.total_worker_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(18, 2)) AS avg_cpu_ms,
    CAST(qs.total_elapsed_time / 1000.0 AS decimal(18, 2)) AS total_duration_ms,
    CAST(qs.total_elapsed_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(18, 2)) AS avg_duration_ms,
    qs.total_logical_reads,
    qs.total_logical_reads / NULLIF(qs.execution_count, 0) AS avg_logical_reads,
    qs.total_logical_writes,
    qs.total_logical_writes / NULLIF(qs.execution_count, 0) AS avg_logical_writes,
    qs.creation_time,
    qs.last_execution_time,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        CASE qs.statement_end_offset
            WHEN -1 THEN (DATALENGTH(st.text) - qs.statement_start_offset) / 2 + 1
            ELSE (qs.statement_end_offset - qs.statement_start_offset) / 2 + 1
        END
    ) AS statement_text,
    st.text AS batch_text,
    qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY qs.total_worker_time DESC;