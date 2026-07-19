-- Consolidate overlapping permissive policies so each role/action pair
-- evaluates one policy while preserving the same access rules.

drop policy roles_authenticated_read on public.roles;
drop policy roles_admin_manage on public.roles;

create policy roles_authenticated_read
on public.roles
for select
to authenticated
using (true);

create policy roles_admin_insert
on public.roles
for insert
to authenticated
with check ((select private.is_admin()));

create policy roles_admin_update
on public.roles
for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy roles_admin_delete
on public.roles
for delete
to authenticated
using ((select private.is_admin()));

drop policy permissions_authenticated_read on public.permissions;
drop policy permissions_admin_manage on public.permissions;

create policy permissions_authenticated_read
on public.permissions
for select
to authenticated
using (true);

create policy permissions_admin_insert
on public.permissions
for insert
to authenticated
with check ((select private.is_admin()));

create policy permissions_admin_update
on public.permissions
for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy permissions_admin_delete
on public.permissions
for delete
to authenticated
using ((select private.is_admin()));

drop policy profiles_read_own on public.profiles;
drop policy profiles_update_own on public.profiles;
drop policy profiles_admin_manage on public.profiles;

create policy profiles_read_own_or_admin
on public.profiles
for select
to authenticated
using (
  (select auth.uid()) = id
  or (select private.is_admin())
);

create policy profiles_admin_insert
on public.profiles
for insert
to authenticated
with check ((select private.is_admin()));

create policy profiles_update_own_or_admin
on public.profiles
for update
to authenticated
using (
  (select auth.uid()) = id
  or (select private.is_admin())
)
with check (
  (select auth.uid()) = id
  or (select private.is_admin())
);

create policy profiles_admin_delete
on public.profiles
for delete
to authenticated
using ((select private.is_admin()));

drop policy role_permissions_authenticated_read on public.role_permissions;
drop policy role_permissions_admin_manage on public.role_permissions;

create policy role_permissions_authenticated_read
on public.role_permissions
for select
to authenticated
using (true);

create policy role_permissions_admin_insert
on public.role_permissions
for insert
to authenticated
with check ((select private.is_admin()));

create policy role_permissions_admin_update
on public.role_permissions
for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy role_permissions_admin_delete
on public.role_permissions
for delete
to authenticated
using ((select private.is_admin()));

drop policy user_roles_read_own on public.user_roles;
drop policy user_roles_admin_manage on public.user_roles;

create policy user_roles_read_own_or_admin
on public.user_roles
for select
to authenticated
using (
  (select auth.uid()) = user_id
  or (select private.is_admin())
);

create policy user_roles_admin_insert
on public.user_roles
for insert
to authenticated
with check ((select private.is_admin()));

create policy user_roles_admin_update
on public.user_roles
for update
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

create policy user_roles_admin_delete
on public.user_roles
for delete
to authenticated
using ((select private.is_admin()));