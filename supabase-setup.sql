-- ============================================
-- StakeholderMap — Supabase Database Setup
-- ============================================
-- Run this ONCE in your Supabase dashboard:
-- Go to SQL Editor → New Query → Paste this → Click Run
-- ============================================

-- Maps table (stores all stakeholder maps)
create table public.maps (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null default 'Untitled Map',
  type text not null default 'project' check (type in ('product', 'project', 'portfolio')),
  description text default '',
  stakeholders jsonb default '[]'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Secure: users can only access their own maps
alter table public.maps enable row level security;

create policy "Users can view own maps"
  on public.maps for select
  using (auth.uid() = user_id);

create policy "Users can create own maps"
  on public.maps for insert
  with check (auth.uid() = user_id);

create policy "Users can update own maps"
  on public.maps for update
  using (auth.uid() = user_id);

create policy "Users can delete own maps"
  on public.maps for delete
  using (auth.uid() = user_id);

-- Auto-update the updated_at timestamp
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger maps_updated_at
  before update on public.maps
  for each row execute function public.update_updated_at();

-- Index for fast user lookups
create index maps_user_id_idx on public.maps(user_id);
create index maps_type_idx on public.maps(type);
