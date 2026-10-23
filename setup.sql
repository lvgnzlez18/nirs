-- Roofing Project Hub: run this once in Supabase > SQL Editor > New query > Run.

create table if not exists public.projects (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.updates (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.settings (
  key text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Only signed-in team members can read or change anything.
do $$
declare t text;
begin
  foreach t in array array['projects','updates','settings'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "team read" on public.%I', t);
    execute format('drop policy if exists "team insert" on public.%I', t);
    execute format('drop policy if exists "team update" on public.%I', t);
    execute format('drop policy if exists "team delete" on public.%I', t);
    execute format('create policy "team read" on public.%I for select to authenticated using (true)', t);
    execute format('create policy "team insert" on public.%I for insert to authenticated with check (true)', t);
    execute format('create policy "team update" on public.%I for update to authenticated using (true) with check (true)', t);
    execute format('create policy "team delete" on public.%I for delete to authenticated using (true)', t);
  end loop;
end $$;

-- Live updates: new messages appear without refreshing.
alter publication supabase_realtime add table public.projects, public.updates, public.settings;
