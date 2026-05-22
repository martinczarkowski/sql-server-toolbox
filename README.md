# SQL Server Toolbox

A collection of practical SQL Server scripts, checklists and T-SQL patterns for database-heavy backend development.

This repository focuses on things I care about in real-world systems:

- database health checks
- migration safety
- performance troubleshooting
- T-SQL patterns
- SQL Server 2016+ compatibility
- backend/database integration

The goal is not to provide magic scripts.  
The goal is to make investigation, maintenance and deployment safer and more repeatable.

## Contents

- `scripts/00-environment-info` - SQL Server and database metadata
- `scripts/01-health-checks` - indexes, foreign keys, table sizes and consistency checks
- `scripts/02-performance-diagnostics` - CPU, blocking and query diagnostics
- `scripts/05-t-sql-patterns` - reusable T-SQL templates
- `docs` - deployment and migration checklists

## Compatibility

Most scripts are written with SQL Server 2016+ in mind.

## Disclaimer

Use these scripts carefully.  
Read them before running them.  
Production databases do not forgive copy-paste heroism.
