-- ============================================================
-- Codcentral Studios — Supabase Schema
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- Existing installations should run supabase-admin-auth-migration.sql instead
-- of re-running this full schema.
-- ============================================================

-- Enable UUID extension (already on by default in Supabase)
create extension if not exists "uuid-ossp";

-- ─────────────────────────────────────────
-- CONTENT
-- ─────────────────────────────────────────

create table if not exists news_articles (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  category    text,
  author      text,
  excerpt     text,
  content     text,
  image_url   text,
  status      text default 'draft' check (status in ('draft','published')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table if not exists blogs (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  tag         text,
  read_time   text,
  author      text,
  excerpt     text,
  content     text,
  image_url   text,
  status      text default 'draft' check (status in ('draft','published')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

create table if not exists newsletters (
  id               uuid primary key default uuid_generate_v4(),
  subject          text not null,
  preview_text     text,
  body             text,
  status           text default 'draft' check (status in ('draft','scheduled','sent')),
  recipient_count  integer default 0,
  sent_at          timestamptz,
  created_at       timestamptz default now()
);

create table if not exists photos (
  id          uuid primary key default uuid_generate_v4(),
  url         text not null,
  title       text,
  alt_text    text,
  caption     text,
  category    text,
  created_at  timestamptz default now()
);

create table if not exists videos (
  id              uuid primary key default uuid_generate_v4(),
  title           text not null,
  url             text not null,
  thumbnail_url   text,
  description     text,
  category        text,
  status          text default 'draft' check (status in ('draft','published')),
  created_at      timestamptz default now()
);

-- ─────────────────────────────────────────
-- PAGES
-- ─────────────────────────────────────────

-- Generic key-value page content store
create table if not exists page_content (
  id         uuid primary key default uuid_generate_v4(),
  page       text unique not null,   -- 'home', 'navbar', 'about', etc.
  content    jsonb default '{}',
  updated_at timestamptz default now()
);

create table if not exists resources (
  id              uuid primary key default uuid_generate_v4(),
  title           text not null,
  type            text,              -- guide, template, tool, ebook, video
  category        text,
  description     text,
  url             text,
  thumbnail_url   text,
  status          text default 'draft' check (status in ('draft','published')),
  created_at      timestamptz default now()
);

create table if not exists shop_products (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  price       numeric(12,2) default 0,
  category    text,
  description text,
  image_url   text,
  stock       integer default 0,
  status      text default 'active' check (status in ('active','draft','sold_out')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ─────────────────────────────────────────
-- OPERATIONS
-- ─────────────────────────────────────────

create table if not exists events (
  id                uuid primary key default uuid_generate_v4(),
  name              text not null,
  event_date        timestamptz,
  location          text,
  description       text,
  capacity          integer,
  registration_url  text,
  image_url         text,
  status            text default 'upcoming' check (status in ('upcoming','past','cancelled')),
  created_at        timestamptz default now()
);

create table if not exists interns (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  email       text not null,
  phone       text,
  department  text,
  school      text,
  start_date  date,
  end_date    date,
  notes       text,
  status      text default 'applicant' check (status in ('applicant','active','completed')),
  created_at  timestamptz default now()
);

-- ─────────────────────────────────────────
-- ACCOUNT
-- ─────────────────────────────────────────

create table if not exists users (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  email       text unique not null,
  role        text default 'viewer' check (role in ('admin','editor','viewer')),
  status      text default 'active' check (status in ('active','inactive')),
  avatar_url  text,
  created_at  timestamptz default now()
);

create table if not exists settings (
  id          uuid primary key default uuid_generate_v4(),
  key         text unique not null,  -- 'global'
  value       jsonb default '{}',
  updated_at  timestamptz default now()
);

-- Seed a default settings row
insert into settings (key, value)
values ('global', '{
  "site_name": "Codcentral Studios",
  "site_tagline": "Global Digital Growth Partner",
  "contact_email": "work.codcentral@gmail.com",
  "contact_phone": "0754 138 667",
  "whatsapp_number": "+256754138667",
  "whatsapp_chat_label": "Chat with us",
  "whatsapp_cta1": "💬 Get a free consultation",
  "whatsapp_cta2": "🚀 See our work & results",
  "whatsapp_cta3": "💰 Get pricing & packages",
  "whatsapp_widget": true,
  "show_shop": false,
  "show_insights": true
}')
on conflict (key) do nothing;

-- ─────────────────────────────────────────
-- ROW LEVEL SECURITY (optional but recommended)
-- ─────────────────────────────────────────
-- Enable RLS and restrict all writes to authenticated users.
-- Reads can remain public for tables that feed the front-end.

alter table news_articles  enable row level security;
alter table blogs           enable row level security;
alter table newsletters     enable row level security;
alter table photos          enable row level security;
alter table videos          enable row level security;
alter table page_content    enable row level security;
alter table resources       enable row level security;
alter table shop_products   enable row level security;
alter table events          enable row level security;
alter table interns         enable row level security;
alter table users           enable row level security;
alter table settings        enable row level security;

-- Public read for content tables
create policy "Public read news"       on news_articles  for select using (status = 'published');
create policy "Public read blogs"      on blogs           for select using (status = 'published');
create policy "Public read photos"     on photos          for select using (true);
create policy "Public read videos"     on videos          for select using (status = 'published');
create policy "Public read resources"  on resources       for select using (status = 'published');
create policy "Public read events"     on events          for select using (true);
create policy "Public read settings"   on settings        for select using (true);
create policy "Public read page_content" on page_content  for select using (true);
create policy "Public read shop"       on shop_products   for select using (status = 'active');

-- Authenticated users can do everything (dashboard users)
create policy "Auth full access news"       on news_articles  for all using (auth.role() = 'authenticated');
create policy "Auth full access blogs"      on blogs           for all using (auth.role() = 'authenticated');
create policy "Auth full access newsletters"on newsletters     for all using (auth.role() = 'authenticated');
create policy "Auth full access photos"     on photos          for all using (auth.role() = 'authenticated');
create policy "Auth full access videos"     on videos          for all using (auth.role() = 'authenticated');
create policy "Auth full access page"       on page_content    for all using (auth.role() = 'authenticated');
create policy "Auth full access resources"  on resources       for all using (auth.role() = 'authenticated');
create policy "Auth full access shop"       on shop_products   for all using (auth.role() = 'authenticated');
create policy "Auth full access events"     on events          for all using (auth.role() = 'authenticated');
create policy "Auth full access interns"    on interns         for all using (auth.role() = 'authenticated');
create policy "Auth full access users"      on users           for all using (auth.role() = 'authenticated');
create policy "Auth full access settings"   on settings        for all using (auth.role() = 'authenticated');

-- ─────────────────────────────────────────
-- CONTACT SUBMISSIONS
-- Run this block in Supabase SQL Editor
-- ─────────────────────────────────────────

create table if not exists contact_submissions (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  email       text not null,
  company     text,
  budget      text,
  service     text,
  brief       text,
  status      text default 'new' check (status in ('new','read','replied','archived')),
  created_at  timestamptz default now()
);

alter table contact_submissions enable row level security;

-- Anyone can INSERT (public contact form)
create policy "Public insert contact"
  on contact_submissions for insert
  with check (true);

-- Only authenticated users can read/update/delete
create policy "Auth read contact"
  on contact_submissions for select
  using (auth.role() = 'authenticated');

create policy "Auth update contact"
  on contact_submissions for update
  using (auth.role() = 'authenticated');

create policy "Auth delete contact"
  on contact_submissions for delete
  using (auth.role() = 'authenticated');

-- ─────────────────────────────────────────
-- ADMIN AUTHORIZATION
-- Create an account in Supabase Auth, then run:
-- insert into public.user_roles (user_id, role)
-- values ('<auth.users UUID>', 'admin');
-- ─────────────────────────────────────────

create table if not exists user_roles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  role       text not null check (role in ('admin')),
  created_at timestamptz not null default now()
);

alter table user_roles enable row level security;
grant select, insert, update, delete on public.user_roles to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles
    where user_id = auth.uid()
      and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

create policy "Users read own role or admins read all"
  on user_roles for select
  using (auth.uid() = user_id or public.is_admin());

create policy "Admins manage roles"
  on user_roles for all
  using (public.is_admin())
  with check (public.is_admin());

-- Remove the temporary anonymous write policies and the broader
-- authenticated-user policies created earlier in this file.
drop policy if exists "Open full access blogs" on blogs;
drop policy if exists "Open full access photos" on photos;
drop policy if exists "Open full access news" on news_articles;
drop policy if exists "Open full access newsletters" on newsletters;
drop policy if exists "Open full access videos" on videos;
drop policy if exists "Open full access events" on events;
drop policy if exists "Open full access interns" on interns;
drop policy if exists "Open full access users" on users;
drop policy if exists "Open full access settings" on settings;
drop policy if exists "Open full access page" on page_content;
drop policy if exists "Open full access resources" on resources;
drop policy if exists "Open full access shop" on shop_products;

drop policy if exists "Auth full access news" on news_articles;
drop policy if exists "Auth full access blogs" on blogs;
drop policy if exists "Auth full access newsletters" on newsletters;
drop policy if exists "Auth full access photos" on photos;
drop policy if exists "Auth full access videos" on videos;
drop policy if exists "Auth full access page" on page_content;
drop policy if exists "Auth full access resources" on resources;
drop policy if exists "Auth full access shop" on shop_products;
drop policy if exists "Auth full access events" on events;
drop policy if exists "Auth full access interns" on interns;
drop policy if exists "Auth full access users" on users;
drop policy if exists "Auth full access settings" on settings;
drop policy if exists "Auth read contact" on contact_submissions;
drop policy if exists "Auth update contact" on contact_submissions;
drop policy if exists "Auth delete contact" on contact_submissions;

create policy "Admins manage news" on news_articles
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage blogs" on blogs
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage newsletters" on newsletters
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage photos" on photos
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage videos" on videos
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage page content" on page_content
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage resources" on resources
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage shop products" on shop_products
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage events" on events
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage interns" on interns
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage users" on users
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage settings" on settings
  for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins manage contact submissions" on contact_submissions
  for all using (public.is_admin()) with check (public.is_admin());
