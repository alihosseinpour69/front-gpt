-- Portfolio backend for Supabase
-- 1) Run this file in Supabase SQL Editor.
-- 2) Create your admin user in Authentication > Users.
-- 3) Replace ADMIN_USER_UUID below with that user's UUID, then run the final INSERT.

create extension if not exists pgcrypto;

create table if not exists public.site_profile (
  id integer primary key default 1 check (id = 1),
  name text not null default 'نام شما',
  title text not null default 'Front-End Developer',
  bio text not null default 'رابط‌های سریع، تمیز و ریسپانسیو می‌سازم؛ با تمرکز روی تجربه کاربری، جزئیات بصری و کدنویسی قابل نگهداری.',
  about text not null default 'من توسعه‌دهنده فرانت‌اند هستم و به ساخت رابط‌های کاربری ساده، سریع و حرفه‌ای علاقه دارم.',
  email text not null default 'you@example.com',
  avatar_url text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  tags text[] not null default '{}',
  image_url text not null default '',
  project_url text not null default '',
  github_url text not null default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.portfolio_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

insert into public.site_profile (id) values (1)
on conflict (id) do nothing;

alter table public.site_profile enable row level security;
alter table public.projects enable row level security;
alter table public.portfolio_admins enable row level security;

-- Everyone can read the public portfolio.
drop policy if exists "Public can read profile" on public.site_profile;
create policy "Public can read profile" on public.site_profile
for select using (true);

drop policy if exists "Public can read projects" on public.projects;
create policy "Public can read projects" on public.projects
for select using (true);

-- Only the listed admin user can mutate content.
drop policy if exists "Admin can update profile" on public.site_profile;
create policy "Admin can update profile" on public.site_profile
for update using (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()));

drop policy if exists "Admin can insert projects" on public.projects;
create policy "Admin can insert projects" on public.projects
for insert with check (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()));

drop policy if exists "Admin can update projects" on public.projects;
create policy "Admin can update projects" on public.projects
for update using (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()));

drop policy if exists "Admin can delete projects" on public.projects;
create policy "Admin can delete projects" on public.projects
for delete using (exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid()));

-- Admin list is not public; an authenticated user can only see their own row.
drop policy if exists "Admin can read own membership" on public.portfolio_admins;
create policy "Admin can read own membership" on public.portfolio_admins
for select using (user_id = auth.uid());

-- Storage bucket for avatars and project images.
insert into storage.buckets (id, name, public)
values ('portfolio', 'portfolio', true)
on conflict (id) do update set public = true;

-- Public image viewing.
drop policy if exists "Public can view portfolio images" on storage.objects;
create policy "Public can view portfolio images" on storage.objects
for select using (bucket_id = 'portfolio');

-- Only admin can upload/change/delete images.
drop policy if exists "Admin can upload portfolio images" on storage.objects;
create policy "Admin can upload portfolio images" on storage.objects
for insert with check (
  bucket_id = 'portfolio' and
  exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid())
);

drop policy if exists "Admin can update portfolio images" on storage.objects;
create policy "Admin can update portfolio images" on storage.objects
for update using (
  bucket_id = 'portfolio' and
  exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid())
) with check (
  bucket_id = 'portfolio' and
  exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid())
);

drop policy if exists "Admin can delete portfolio images" on storage.objects;
create policy "Admin can delete portfolio images" on storage.objects
for delete using (
  bucket_id = 'portfolio' and
  exists (select 1 from public.portfolio_admins a where a.user_id = auth.uid())
);

-- IMPORTANT: after creating the admin in Authentication > Users,
-- replace ADMIN_USER_UUID and run this statement separately:
-- insert into public.portfolio_admins (user_id)
-- values ('ADMIN_USER_UUID')
-- on conflict (user_id) do nothing;
