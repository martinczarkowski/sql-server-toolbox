/*
Purpose:
  Shows currently blocked sessions and their blockers.

Notes:
  - Read-only.
  - Run while the issue is happening. Blocking is a live-state problem.
  - Requires permissions to see sessions and requests, typically VIEW SERVER STATE.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

SELECT
    r.session_id AS blocked_session_id,
    r.blocking_session_id,
    r.status,
    r.command,
    DB_NAME(r.database_id) AS database_name,
    r.wait_type,
    r.wait_time AS wait_time_ms,
    r.wait_resource,
    r.cpu_time AS cpu_time_ms,
    r.total_elapsed_time AS total_elapsed_time_ms,
    r.reads,
    r.writes,
    r.logical_reads,
    blocked_s.login_name AS blocked_login_name,
    blocked_s.host_name AS blocked_host_name,
    blocked_s.program_name AS blocked_program_name,
    blocker_s.login_name AS blocker_login_name,
    blocker_s.host_name AS blocker_host_name,
    blocker_s.program_name AS blocker_program_name,
    blocked_text.text AS blocked_batch_text,
    blocker_text.text AS blocker_batch_text
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS blocked_s
    ON blocked_s.session_id = r.session_id
LEFT JOIN sys.dm_exec_sessions AS blocker_s
    ON blocker_s.session_id = r.blocking_session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS blocked_text
OUTER APPLY
(
    SELECT er.sql_handle
    FROM sys.dm_exec_requests AS er
    WHERE er.session_id = r.blocking_session_id
) AS blocker_request
OUTER APPLY sys.dm_exec_sql_text(blocker_request.sql_handle) AS blocker_text
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

SELECT
    tl.resource_type,
    tl.resource_database_id,
    DB_NAME(tl.resource_database_id) AS database_name,
    tl.resource_associated_entity_id,
    tl.request_mode,
    tl.request_status,
    tl.request_session_id,
    s.login_name,
    s.host_name,
    s.program_name
FROM sys.dm_tran_locks AS tl
LEFT JOIN sys.dm_exec_sessions AS s
    ON s.session_id = tl.request_session_id
WHERE tl.request_status IN ('WAIT', 'CONVERT')
ORDER BY tl.request_session_id, tl.resource_type;