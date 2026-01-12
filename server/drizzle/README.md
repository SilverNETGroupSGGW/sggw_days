# Drizzle Migrations

This directory contains auto-generated SQL migration files created by `drizzle-kit`.

## Migration Files

Each file represents a schema change:

- Files are numbered sequentially: `0000_*.sql`, `0001_*.sql`, etc.
- Applied automatically on server startup via `migrate()` in `database.ts`

## Workflow

1. **Modify Schema**: Edit `schema.ts`
2. **Generate Migration**: Run `bun run db:generate`
3. **Review SQL**: Check the generated `.sql` file
4. **Apply**: Migrations run automatically on next server start

## Manual Commands

```bash
# Generate new migration
bun run db:generate

# Apply migrations manually
bun run db:migrate

# Push schema directly (dev only)
bun run db:push
```

Do not edit migration files manually - regenerate them if needed.
