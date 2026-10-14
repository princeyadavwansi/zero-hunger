-- Share a Meal: Supabase starter schema
-- Run this in Supabase Dashboard > SQL Editor.
-- Public visitors can submit and read community listings.
-- Only authenticated users with app_metadata.role = 'admin' can update/delete listings.
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
create policy "Anyone can view approved and pending listings"
on public.listings for select to anon, authenticated
using (status in ('Pending','Approved','Completed'));

drop policy if exists "Visitors can submit listings" on public.listings;
create policy "Visitors can submit listings"
on public.listings for insert to anon, authenticated
with check (status = 'Pending');

drop policy if exists "Admins can update listings" on public.listings;
create policy "Admins can update listings"
on public.listings for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can delete listings" on public.listings;
create policy "Admins can delete listings"
on public.listings for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Visitors can submit feedback" on public.feedback;
create policy "Visitors can submit feedback"
on public.feedback for insert to anon, authenticated
with check (true);

drop policy if exists "Admins can read feedback" on public.feedback;
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
