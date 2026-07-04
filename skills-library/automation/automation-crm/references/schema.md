# CRM — modelo de datos mínimo (Supabase / Postgres)

> Esquema base para la Vía A (Supabase). Twenty ya trae su propio modelo equivalente
> (People/Companies/Opportunities/Activities) — en ese caso se usa su API GraphQL, no este SQL.

```sql
-- Empresas
create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  domain text unique,
  sector text,
  created_at timestamptz default now()
);

-- Contactos (dedup por email)
create table if not exists contacts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  full_name text not null,
  email text unique,
  phone text,
  role text,
  source text,                       -- prospecting, referido, inbound...
  created_at timestamptz default now()
);

-- Oportunidades / deals
create table if not exists deals (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  contact_id uuid references contacts(id) on delete set null,
  title text not null,
  amount numeric,
  currency text default 'EUR',
  stage text not null default 'lead', -- lead|qualified|proposal|won|lost
  probability numeric,                -- 0-1
  close_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Actividades (llamadas, emails, notas)
create table if not exists activities (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid references deals(id) on delete cascade,
  contact_id uuid references contacts(id) on delete set null,
  kind text not null,                 -- call|email|note|meeting
  body text,
  occurred_at timestamptz default now()
);
```

## Notas
- **RLS on** en todas las tablas (RGPD); políticas según quién accede. Claves de servicio solo en `.env`.
- `deals.stage`/`probability` son justo lo que `sales-pipeline-forecast` necesita para su previsión.
- Export para forecast: `select` de `deals` con company/contact join → CSV.
- Twenty: mapear People→contacts, Companies→companies, Opportunities→deals, Activities→activities.
