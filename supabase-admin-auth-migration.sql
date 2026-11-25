-- Apply this migration to an existing project after its content tables exist.
-- Then create an Auth user and insert its Auth UUID:
-- insert into public.user_roles (user_id, role)
-- values ('<auth.users UUID>', 'admin');

create table if not exists public.user_roles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  role       text not null check (role in ('admin')),
  created_at timestamptz not null default now()
);

alter table public.user_roles enable row level security;
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

drop policy if exists "Users read own role or admins read all" on public.user_roles;
create policy "Users read own role or admins read all"
  on public.user_roles for select
  using (auth.uid() = user_id or public.is_admin());

drop policy if exists "Admins manage roles" on public.user_roles;
create policy "Admins manage roles"
  on public.user_roles for all
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Open full access blogs" on public.blogs;
drop policy if exists "Open full access photos" on public.photos;
drop policy if exists "Open full access news" on public.news_articles;
drop policy if exists "Open full access newsletters" on public.newsletters;
drop policy if exists "Open full access videos" on public.videos;
drop policy if exists "Open full access events" on public.events;
drop policy if exists "Open full access interns" on public.interns;
drop policy if exists "Open full access users" on public.users;
drop policy if exists "Open full access settings" on public.settings;
drop policy if exists "Open full access page" on public.page_content;
drop policy if exists "Open full access resources" on public.resources;
drop policy if exists "Open full access shop" on public.shop_products;

drop policy if exists "Auth full access news" on public.news_articles;
drop policy if exists "Auth full access blogs" on public.blogs;
drop policy if exists "Auth full access newsletters" on public.newsletters;
drop policy if exists "Auth full access photos" on public.photos;
drop policy if exists "Auth full access videos" on public.videos;
drop policy if exists "Auth full access page" on public.page_content;
drop policy if exists "Auth full access resources" on public.resources;
drop policy if exists "Auth full access shop" on public.shop_products;
drop policy if exists "Auth full access events" on public.events;
drop policy if exists "Auth full access interns" on public.interns;
drop policy if exists "Auth full access users" on public.users;
drop policy if exists "Auth full access settings" on public.settings;
drop policy if exists "Auth read contact" on public.contact_submissions;
drop policy if exists "Auth update contact" on public.contact_submissions;
drop policy if exists "Auth delete contact" on public.contact_submissions;

alter table public.news_articles enable row level security;
alter table public.blogs enable row level security;

grant select on public.news_articles, public.blogs to anon, authenticated;

drop policy if exists "Public read news" on public.news_articles;
create policy "Public read news" on public.news_articles
  for select using (status = 'published');

drop policy if exists "Public read blogs" on public.blogs;
create policy "Public read blogs" on public.blogs
  for select using (status = 'published');

drop policy if exists "Admins manage news" on public.news_articles;
create policy "Admins manage news" on public.news_articles
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage blogs" on public.blogs;
create policy "Admins manage blogs" on public.blogs
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage newsletters" on public.newsletters;
create policy "Admins manage newsletters" on public.newsletters
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage photos" on public.photos;
create policy "Admins manage photos" on public.photos
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage videos" on public.videos;
create policy "Admins manage videos" on public.videos
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage page content" on public.page_content;
create policy "Admins manage page content" on public.page_content
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage resources" on public.resources;
create policy "Admins manage resources" on public.resources
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage shop products" on public.shop_products;
create policy "Admins manage shop products" on public.shop_products
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage events" on public.events;
create policy "Admins manage events" on public.events
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage interns" on public.interns;
create policy "Admins manage interns" on public.interns
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage users" on public.users;
create policy "Admins manage users" on public.users
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage settings" on public.settings;
create policy "Admins manage settings" on public.settings
  for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins manage contact submissions" on public.contact_submissions;
create policy "Admins manage contact submissions" on public.contact_submissions
  for all using (public.is_admin()) with check (public.is_admin());
