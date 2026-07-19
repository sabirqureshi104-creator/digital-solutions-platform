-- Initial authentication and authorization foundation.

-- Supabase's automatic-RLS helper is an event-trigger function, not a public RPC.
-- Remove the default EXECUTE privilege while preserving the event trigger itself.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create type public.profile_status as enum ('active', 'inactive');

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  description text,
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint roles_name_not_blank check (length(btrim(name)) > 0),
  constraint roles_slug_format check (slug ~ '^[a-z][a-z0-9_-]*$'),
  constraint roles_name_unique unique (name),
  constraint roles_slug_unique unique (slug)
);

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint permissions_name_not_blank check (length(btrim(name)) > 0),
  constraint permissions_slug_format check (slug ~ '^[a-z][a-z0-9_.-]*$'),
  constraint permissions_name_unique unique (name),
  constraint permissions_slug_unique unique (slug)
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  phone text,
  job_title text,
  status public.profile_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_display_name_not_blank
    check (display_name is null or length(btrim(display_name)) > 0)
);

create table public.role_permissions (
  role_id uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (role_id, permission_id)
);

create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role_id uuid not null references public.roles(id) on delete cascade,
  assigned_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, role_id)
);

create index role_permissions_permission_id_idx
  on public.role_permissions(permission_id);

create index user_roles_role_id_idx
  on public.user_roles(role_id);

create index user_roles_assigned_by_idx
  on public.user_roles(assigned_by)
  where assigned_by is not null;

create index profiles_status_idx
  on public.profiles(status);

insert into public.roles (name, slug, description, is_system)
values
  ('Administrator', 'admin', 'Full access to the administration system.', true),
  ('Content Editor', 'editor', 'Can manage public website content.', true),
  ('Lead Manager', 'lead_manager', 'Can manage leads and customer enquiries.', true)
on conflict (slug) do update
set
  name = excluded.name,
  description = excluded.description,
  is_system = excluded.is_system,
  updated_at = now();

insert into public.permissions (name, slug, description)
values
  ('Access admin', 'admin.access', 'Access the administration area.'),
  ('Manage content', 'content.manage', 'Create, edit, publish, and archive website content.'),
  ('Manage leads', 'leads.manage', 'View, assign, update, and export leads.'),
  ('Manage media', 'media.manage', 'Upload, edit, and remove media assets.'),
  ('Manage SEO', 'seo.manage', 'Manage metadata, redirects, and indexing settings.'),
  ('Manage users', 'users.manage', 'Manage users, roles, and permissions.'),
  ('Manage settings', 'settings.manage', 'Manage global website settings.')
on conflict (slug) do update
set
  name = excluded.name,
  description = excluded.description,
  updated_at = now();

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
cross join public.permissions p
where r.slug = 'admin'
on conflict do nothing;

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
join public.permissions p
  on p.slug in ('admin.access', 'content.manage', 'media.manage', 'seo.manage')
where r.slug = 'editor'
on conflict do nothing;

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
join public.permissions p
  on p.slug in ('admin.access', 'leads.manage')
where r.slug = 'lead_manager'
on conflict do nothing;

create function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function private.set_updated_at() from public, anon, authenticated;

create trigger roles_set_updated_at
before update on public.roles
for each row execute function private.set_updated_at();

create trigger permissions_set_updated_at
before update on public.permissions
for each row execute function private.set_updated_at();

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function private.set_updated_at();

create function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    nullif(
      btrim(
        coalesce(
          new.raw_user_meta_data ->> 'display_name',
          new.raw_user_meta_data ->> 'full_name',
          ''
        )
      ),
      ''
    )
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

revoke all on function private.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_user();

insert into public.profiles (id, display_name)
select
  u.id,
  nullif(
    btrim(
      coalesce(
        u.raw_user_meta_data ->> 'display_name',
        u.raw_user_meta_data ->> 'full_name',
        ''
      )
    ),
    ''
  )
from auth.users u
on conflict (id) do nothing;

create function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and exists (
      select 1
      from public.user_roles ur
      join public.roles r on r.id = ur.role_id
      join public.profiles p on p.id = ur.user_id
      where ur.user_id = (select auth.uid())
        and r.slug = 'admin'
        and p.status = 'active'
    );
$$;

revoke all on function private.is_admin() from public, anon, authenticated;
grant usage on schema private to authenticated;
grant execute on function private.is_admin() to authenticated;

alter table public.roles enable row level security;
alter table public.permissions enable row level security;
alter table public.profiles enable row level security;
alter table public.role_permissions enable row level security;
alter table public.user_roles enable row level security;

revoke all on table public.roles from anon, authenticated;
revoke all on table public.permissions from anon, authenticated;
revoke all on table public.profiles from anon, authenticated;
revoke all on table public.role_permissions from anon, authenticated;
revoke all on table public.user_roles from anon, authenticated;

grant select, insert, update, delete on table public.roles to authenticated;
grant select, insert, update, delete on table public.permissions to authenticated;
grant select, insert, update, delete on table public.profiles to authenticated;
grant select, insert, update, delete on table public.role_permissions to authenticated;
grant select, insert, update, delete on table public.user_roles to authenticated;

create policy roles_authenticated_read
on public.roles
for select
to authenticated
using (true);

create policy roles_admin_manage
on public.roles
for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy permissions_authenticated_read
on public.permissions
for select
to authenticated
using (true);

create policy permissions_admin_manage
on public.permissions
for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy profiles_read_own
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

create policy profiles_update_own
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy profiles_admin_manage
on public.profiles
for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy role_permissions_authenticated_read
on public.role_permissions
for select
to authenticated
using (true);

create policy role_permissions_admin_manage
on public.role_permissions
for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy user_roles_read_own
on public.user_roles
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy user_roles_admin_manage
on public.user_roles
for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));