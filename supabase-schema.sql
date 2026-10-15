-- Share a Meal: secure Supabase schema and migration
-- Run the COMPLETE file in Supabase Dashboard > SQL Editor.
-- Frontend users authenticate with Supabase Auth. Never put a service-role key in browser code.
create extension if not exists pgcrypto;

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('request','donation','volunteer')),
  name text not null default 'Community member',
  area text not null,
  details jsonb not null default '{}'::jsonb,
  status text not null default 'Pending'
    check (status in ('Pending','Approved','Completed','Rejected')),
  created_at timestamptz not null default now()
);

-- Safe migration for an existing project.
alter table public.listings add column if not exists user_id uuid references auth.users(id) on delete set null;
create index if not exists listings_user_id_created_at_idx on public.listings(user_id, created_at desc);

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  waste_rating text,
  desired_feature text,
  suggestion text,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete cascade,
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.listings enable row level security;
alter table public.feedback enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Anyone can view approved and pending listings" on public.listings;
drop policy if exists "Visitors can submit listings" on public.listings;
drop policy if exists "Admins can update listings" on public.listings;
drop policy if exists "Admins can delete listings" on public.listings;
drop policy if exists "Public can view approved listings" on public.listings;
drop policy if exists "Users can view own listings or public approved listings" on public.listings;
drop policy if exists "Authenticated users submit own pending listings" on public.listings;
drop policy if exists "Admins can view all listings" on public.listings;
drop policy if exists "Admins can manage listings" on public.listings;

-- Public board: only approved/completed entries are visible to everyone.
create policy "Public can view approved listings"
on public.listings for select to anon
using (status in ('Approved','Completed'));

-- Signed-in users can see their own requests, approved public entries, and all rows as admins.
create policy "Users can view own listings or public approved listings"
on public.listings for select to authenticated
using (
  user_id = (select auth.uid())
  or status in ('Approved','Completed')
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

create policy "Authenticated users submit own pending listings"
on public.listings for insert to authenticated
with check (user_id = (select auth.uid()) and status = 'Pending');

create policy "Admins can manage listings"
on public.listings for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Visitors can submit feedback" on public.feedback;
drop policy if exists "Admins can read feedback" on public.feedback;
create policy "Visitors can submit feedback"
on public.feedback for insert to anon, authenticated
with check (true);
create policy "Admins can read feedback"
on public.feedback for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can manage notifications" on public.notifications;
create policy "Admins can manage notifications"
on public.notifications for all to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create index if not exists listings_created_at_idx on public.listings (created_at desc);
create index if not exists listings_status_idx on public.listings (status);
create index if not exists notifications_created_at_idx on public.notifications (created_at desc);

-- Table grants are separate from RLS. RLS remains the row/action security boundary.
revoke insert, update, delete on table public.listings from anon;
grant select on table public.listings to anon;
grant select, insert, update, delete on table public.listings to authenticated;
grant insert on table public.feedback to anon, authenticated;
grant select on table public.feedback to authenticated;
grant select, insert, update, delete on table public.notifications to authenticated;
