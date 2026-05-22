# EF Core Migration Review Checklist

A checklist for reviewing Entity Framework Core migrations targeting SQL Server.

EF Core is good at generating SQL. Production databases are good at proving that generated SQL still needs human review.

## General review

- Read the generated migration code.
- Generate and review the SQL script before deployment.
- Check whether the migration is idempotent when your deployment process requires it.
- Verify the migration was tested against realistic data volume, not only an empty local database.
- Confirm the migration works with the target SQL Server version and compatibility level.

## High-risk operations

Look carefully for:

- `DROP TABLE`
- `DROP COLUMN`
- column type changes
- string length reductions
- nullability changes from nullable to non-nullable
- table rebuilds
- large index rebuilds
- foreign key drops and recreations
- data movement in one large transaction

## Data safety

- Does the migration preserve existing data?
- Is there a backfill step for new required columns?
- Is the backfill batched for large tables?
- Is the default value temporary or part of the real model?
- Can the migration be rolled back safely?
- Is the rollback script actually safe for production data?

## Indexes and constraints

- Are important indexes explicitly created?
- Are index names stable and readable?
- Are foreign key names stable and readable?
- Are cascade actions intentional?
- Are unique constraints/indexes safe for existing data?
- Could a new constraint fail because of existing dirty data?

## SQL Server specifics

- Check generated data types.
- Check whether `nvarchar(max)` was generated where a smaller length would be better.
- Check decimal precision and scale.
- Check datetime type choices.
- Check default constraints and their names.
- Check whether computed columns, filtered indexes or raw SQL are needed.

## Performance

- Could this migration lock a large table for too long?
- Could it cause transaction log growth?
- Does it rebuild a large table or index?
- Should the migration be split into multiple smaller steps?
- Should data updates be processed in batches?

## Deployment

- Run the migration script in a staging-like environment.
- Capture deployment output.
- Monitor blocking and transaction log growth.
- Run smoke tests after deployment.
- Verify foreign keys and indexes after deployment.

## Notes

EF Core migrations are source code. Treat them like source code:

- review them,
- test them,
- keep them readable,
- and never assume generated SQL is automatically production-safe.
