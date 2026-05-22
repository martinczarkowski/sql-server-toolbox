/*
Purpose:
  Shows SQL Server instance metadata and selected server-level configuration values.

Notes:
  - Read-only.
  - Useful as a first snapshot before troubleshooting, migration or deployment work.
  - Some values may be NULL depending on SQL Server edition, environment and permissions.

Compatibility:
  SQL Server 2016+
*/

SET NOCOUNT ON;

SELECT
    SERVERPROPERTY('ServerName') AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    SERVERPROPERTY('InstanceName') AS instance_name,
    SERVERPROPERTY('Edition') AS edition,
    SERVERPROPERTY('EngineEdition') AS engine_edition_id,
    CASE CONVERT(int, SERVERPROPERTY('EngineEdition'))
        WHEN 1 THEN 'Personal or Desktop Engine'
        WHEN 2 THEN 'Standard'
        WHEN 3 THEN 'Enterprise, Developer or Evaluation'
        WHEN 4 THEN 'Express'
        WHEN 5 THEN 'Azure SQL Database'
        WHEN 6 THEN 'Azure Synapse Analytics'
        WHEN 8 THEN 'Azure SQL Managed Instance'
        WHEN 9 THEN 'Azure SQL Edge'
        ELSE 'Unknown'
    END AS engine_edition_name,
    SERVERPROPERTY('ProductVersion') AS product_version,
    SERVERPROPERTY('ProductLevel') AS product_level,
    SERVERPROPERTY('ProductUpdateLevel') AS product_update_level,
    SERVERPROPERTY('ProductUpdateReference') AS product_update_reference,
    SERVERPROPERTY('Collation') AS server_collation,
    SERVERPROPERTY('IsClustered') AS is_clustered,
    SERVERPROPERTY('IsHadrEnabled') AS is_hadr_enabled,
    SERVERPROPERTY('IsIntegratedSecurityOnly') AS is_integrated_security_only,
    SERVERPROPERTY('FilestreamConfiguredLevel') AS filestream_configured_level,
    SYSDATETIME() AS collected_at;

SELECT @@VERSION AS full_version_string;

SELECT
    c.name,
    c.value,
    c.value_in_use,
    c.minimum,
    c.maximum,
    c.description
FROM sys.configurations AS c
WHERE c.name IN
(
    'backup compression default',
    'clr enabled',
    'cost threshold for parallelism',
    'max degree of parallelism',
    'max server memory (MB)',
    'min server memory (MB)',
    'optimize for ad hoc workloads',
    'remote admin connections'
)
ORDER BY c.name;

IF OBJECT_ID('sys.dm_server_services') IS NOT NULL
BEGIN
    SELECT
        servicename,
        startup_type_desc,
        status_desc,
        last_startup_time,
        service_account,
        is_clustered,
        cluster_nodename,
        filename
    FROM sys.dm_server_services
    ORDER BY servicename;
END;