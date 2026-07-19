-- Core public content, media, SEO, settings, and lead-management schema.

create type public.content_status as enum ('draft', 'published', 'archived');
create type public.media_kind as enum ('image', 'video', 'audio', 'document', 'other');
create type public.project_kind as enum (
  'client',
  'internal',
  'demo',
  'concept',
  'open_source',
  'digital_product'
);
create type public.lead_status as enum (
  'new',
  'reviewed',
  'contacted',
  'qualified',
  'proposal_sent',
  'won',
  'lost',
  'spam',
  'archived'
);
create type public.inquiry_kind as enum (
  'general',
  'quotation',
  'demo',
  'product_support',
  'custom_development',
  'partnership',
  'white_label',
  'maintenance'
);

create function private.has_permission(permission_slug text)
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
      join public.profiles profile on profile.id = ur.user_id
      join public.role_permissions rp on rp.role_id = ur.role_id
      join public.permissions permission on permission.id = rp.permission_id
      where ur.user_id = (select auth.uid())
        and profile.status = 'active'
        and permission.slug = permission_slug
    );
$$;

revoke all on function private.has_permission(text) from public, anon, authenticated;
grant execute on function private.has_permission(text) to authenticated;

create table public.media (
  id uuid primary key default gen_random_uuid(),
  bucket text not null default 'media',
  object_path text not null,
  original_name text not null,
  title text,
  alt_text text,
  mime_type text not null,
  kind public.media_kind not null default 'other',
  size_bytes bigint,
  width integer,
  height integer,
  duration_seconds numeric(12, 3),
  is_public boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  uploaded_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint media_bucket_not_blank check (length(btrim(bucket)) > 0),
  constraint media_object_path_not_blank check (length(btrim(object_path)) > 0),
  constraint media_original_name_not_blank check (length(btrim(original_name)) > 0),
  constraint media_size_nonnegative check (size_bytes is null or size_bytes >= 0),
  constraint media_width_positive check (width is null or width > 0),
  constraint media_height_positive check (height is null or height > 0),
  constraint media_duration_nonnegative check (duration_seconds is null or duration_seconds >= 0),
  constraint media_metadata_object check (jsonb_typeof(metadata) = 'object'),
  constraint media_bucket_path_unique unique (bucket, object_path)
);

create table public.pages (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.pages(id) on delete set null,
  title text not null,
  slug text not null,
  excerpt text,
  body jsonb not null default '{}'::jsonb,
  template text not null default 'default',
  status public.content_status not null default 'draft',
  is_homepage boolean not null default false,
  is_featured boolean not null default false,
  sort_order integer not null default 0,
  published_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pages_title_not_blank check (length(btrim(title)) > 0),
  constraint pages_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint pages_body_object check (jsonb_typeof(body) = 'object'),
  constraint pages_sort_order_nonnegative check (sort_order >= 0),
  constraint pages_slug_unique unique (slug),
  constraint pages_not_own_parent check (parent_id is null or parent_id <> id)
);

create unique index pages_single_homepage_idx
  on public.pages(is_homepage)
  where is_homepage;

create table public.page_sections (
  id uuid primary key default gen_random_uuid(),
  page_id uuid not null references public.pages(id) on delete cascade,
  section_type text not null,
  eyebrow text,
  heading text,
  body text,
  content jsonb not null default '{}'::jsonb,
  settings jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_visible boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint page_sections_type_not_blank check (length(btrim(section_type)) > 0),
  constraint page_sections_content_object check (jsonb_typeof(content) = 'object'),
  constraint page_sections_settings_object check (jsonb_typeof(settings) = 'object'),
  constraint page_sections_sort_order_nonnegative check (sort_order >= 0)
);

create table public.service_categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.service_categories(id) on delete set null,
  name text not null,
  slug text not null,
  description text,
  icon text,
  status public.content_status not null default 'draft',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint service_categories_name_not_blank check (length(btrim(name)) > 0),
  constraint service_categories_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint service_categories_sort_order_nonnegative check (sort_order >= 0),
  constraint service_categories_slug_unique unique (slug),
  constraint service_categories_not_own_parent check (parent_id is null or parent_id <> id)
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.service_categories(id) on delete set null,
  name text not null,
  slug text not null,
  short_description text,
  full_description text,
  hero_media_id uuid references public.media(id) on delete set null,
  features jsonb not null default '[]'::jsonb,
  benefits jsonb not null default '[]'::jsonb,
  business_problems jsonb not null default '[]'::jsonb,
  use_cases jsonb not null default '[]'::jsonb,
  delivery_process jsonb not null default '[]'::jsonb,
  pricing_summary text,
  cta_label text not null default 'Start a Project',
  status public.content_status not null default 'draft',
  is_featured boolean not null default false,
  sort_order integer not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint services_name_not_blank check (length(btrim(name)) > 0),
  constraint services_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint services_features_array check (jsonb_typeof(features) = 'array'),
  constraint services_benefits_array check (jsonb_typeof(benefits) = 'array'),
  constraint services_business_problems_array check (jsonb_typeof(business_problems) = 'array'),
  constraint services_use_cases_array check (jsonb_typeof(use_cases) = 'array'),
  constraint services_delivery_process_array check (jsonb_typeof(delivery_process) = 'array'),
  constraint services_sort_order_nonnegative check (sort_order >= 0),
  constraint services_slug_unique unique (slug)
);

create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.product_categories(id) on delete set null,
  name text not null,
  slug text not null,
  description text,
  icon text,
  status public.content_status not null default 'draft',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint product_categories_name_not_blank check (length(btrim(name)) > 0),
  constraint product_categories_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint product_categories_sort_order_nonnegative check (sort_order >= 0),
  constraint product_categories_slug_unique unique (slug),
  constraint product_categories_not_own_parent check (parent_id is null or parent_id <> id)
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  short_description text,
  full_description text,
  featured_media_id uuid references public.media(id) on delete set null,
  video_url text,
  live_demo_url text,
  documentation_url text,
  buy_url text,
  version text,
  product_models text[] not null default '{}'::text[],
  features jsonb not null default '[]'::jsonb,
  admin_features jsonb not null default '[]'::jsonb,
  customer_features jsonb not null default '[]'::jsonb,
  user_roles jsonb not null default '[]'::jsonb,
  integrations jsonb not null default '[]'::jsonb,
  supported_languages text[] not null default '{}'::text[],
  technical_requirements jsonb not null default '{}'::jsonb,
  support_options jsonb not null default '[]'::jsonb,
  status public.content_status not null default 'draft',
  is_featured boolean not null default false,
  sort_order integer not null default 0,
  published_at timestamptz,
  product_updated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint products_name_not_blank check (length(btrim(name)) > 0),
  constraint products_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint products_features_array check (jsonb_typeof(features) = 'array'),
  constraint products_admin_features_array check (jsonb_typeof(admin_features) = 'array'),
  constraint products_customer_features_array check (jsonb_typeof(customer_features) = 'array'),
  constraint products_user_roles_array check (jsonb_typeof(user_roles) = 'array'),
  constraint products_integrations_array check (jsonb_typeof(integrations) = 'array'),
  constraint products_requirements_object check (jsonb_typeof(technical_requirements) = 'object'),
  constraint products_support_options_array check (jsonb_typeof(support_options) = 'array'),
  constraint products_sort_order_nonnegative check (sort_order >= 0),
  constraint products_slug_unique unique (slug)
);

create table public.product_category_assignments (
  product_id uuid not null references public.products(id) on delete cascade,
  category_id uuid not null references public.product_categories(id) on delete cascade,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  primary key (product_id, category_id),
  constraint product_category_assignments_sort_nonnegative check (sort_order >= 0)
);

create table public.product_packages (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  slug text not null,
  currency text not null default 'USD',
  price numeric(12, 2),
  billing_period text not null default 'one_time',
  description text,
  feature_list jsonb not null default '[]'::jsonb,
  user_limit integer,
  storage_limit text,
  support_period text,
  includes_updates boolean not null default true,
  includes_installation boolean not null default false,
  includes_branding boolean not null default true,
  customization text,
  is_recommended boolean not null default false,
  is_active boolean not null default true,
  cta_label text not null default 'Get Started',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint product_packages_name_not_blank check (length(btrim(name)) > 0),
  constraint product_packages_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint product_packages_currency_format check (currency ~ '^[A-Z]{3}$'),
  constraint product_packages_price_nonnegative check (price is null or price >= 0),
  constraint product_packages_billing_period
    check (billing_period in ('one_time', 'monthly', 'annual', 'custom')),
  constraint product_packages_feature_list_array check (jsonb_typeof(feature_list) = 'array'),
  constraint product_packages_user_limit_positive check (user_limit is null or user_limit > 0),
  constraint product_packages_sort_order_nonnegative check (sort_order >= 0),
  constraint product_packages_product_slug_unique unique (product_id, slug)
);

create table public.industries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  introduction text,
  challenges jsonb not null default '[]'::jsonb,
  example_automations jsonb not null default '[]'::jsonb,
  example_workflows jsonb not null default '[]'::jsonb,
  hero_media_id uuid references public.media(id) on delete set null,
  status public.content_status not null default 'draft',
  is_featured boolean not null default false,
  sort_order integer not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint industries_name_not_blank check (length(btrim(name)) > 0),
  constraint industries_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint industries_challenges_array check (jsonb_typeof(challenges) = 'array'),
  constraint industries_automations_array check (jsonb_typeof(example_automations) = 'array'),
  constraint industries_workflows_array check (jsonb_typeof(example_workflows) = 'array'),
  constraint industries_sort_order_nonnegative check (sort_order >= 0),
  constraint industries_slug_unique unique (slug)
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null,
  client_name text,
  is_client_anonymous boolean not null default false,
  kind public.project_kind not null default 'client',
  problem text,
  previous_process text,
  proposed_solution text,
  features_delivered jsonb not null default '[]'::jsonb,
  technologies text[] not null default '{}'::text[],
  timeline text,
  results text,
  metrics jsonb not null default '{}'::jsonb,
  testimonial_quote text,
  hero_media_id uuid references public.media(id) on delete set null,
  status public.content_status not null default 'draft',
  is_featured boolean not null default false,
  sort_order integer not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint projects_title_not_blank check (length(btrim(title)) > 0),
  constraint projects_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint projects_features_array check (jsonb_typeof(features_delivered) = 'array'),
  constraint projects_metrics_object check (jsonb_typeof(metrics) = 'object'),
  constraint projects_sort_order_nonnegative check (sort_order >= 0),
  constraint projects_slug_unique unique (slug)
);

create table public.industry_services (
  industry_id uuid not null references public.industries(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (industry_id, service_id)
);

create table public.industry_products (
  industry_id uuid not null references public.industries(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (industry_id, product_id)
);

create table public.product_services (
  product_id uuid not null references public.products(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (product_id, service_id)
);

create table public.project_services (
  project_id uuid not null references public.projects(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (project_id, service_id)
);

create table public.project_products (
  project_id uuid not null references public.projects(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (project_id, product_id)
);

create table public.project_industries (
  project_id uuid not null references public.projects(id) on delete cascade,
  industry_id uuid not null references public.industries(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (project_id, industry_id)
);

create table public.seo_metadata (
  id uuid primary key default gen_random_uuid(),
  page_id uuid references public.pages(id) on delete cascade,
  service_id uuid references public.services(id) on delete cascade,
  product_id uuid references public.products(id) on delete cascade,
  industry_id uuid references public.industries(id) on delete cascade,
  project_id uuid references public.projects(id) on delete cascade,
  seo_title text,
  meta_description text,
  canonical_url text,
  open_graph_title text,
  open_graph_description text,
  social_media_id uuid references public.media(id) on delete set null,
  no_index boolean not null default false,
  structured_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint seo_metadata_exactly_one_target
    check (num_nonnulls(page_id, service_id, product_id, industry_id, project_id) = 1),
  constraint seo_metadata_structured_data_object
    check (jsonb_typeof(structured_data) = 'object')
);

create unique index seo_metadata_page_unique
  on public.seo_metadata(page_id)
  where page_id is not null;
create unique index seo_metadata_service_unique
  on public.seo_metadata(service_id)
  where service_id is not null;
create unique index seo_metadata_product_unique
  on public.seo_metadata(product_id)
  where product_id is not null;
create unique index seo_metadata_industry_unique
  on public.seo_metadata(industry_id)
  where industry_id is not null;
create unique index seo_metadata_project_unique
  on public.seo_metadata(project_id)
  where project_id is not null;

create table public.site_settings (
  key text primary key,
  value jsonb not null,
  group_name text not null default 'general',
  description text,
  is_public boolean not null default false,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint site_settings_key_format check (key ~ '^[a-z][a-z0-9_.-]*$'),
  constraint site_settings_group_not_blank check (length(btrim(group_name)) > 0)
);

create table public.leads (
  id uuid primary key default gen_random_uuid(),
  source_page text,
  campaign text,
  inquiry_type public.inquiry_kind not null default 'general',
  name text not null,
  email text not null,
  phone text,
  company text,
  country text,
  industry_id uuid references public.industries(id) on delete set null,
  company_size text,
  current_process text,
  main_problem text,
  required_features text,
  user_count integer,
  existing_software text,
  required_integrations text,
  budget_range text,
  desired_launch_date date,
  attachment_media_id uuid references public.media(id) on delete set null,
  preferred_contact_method text,
  message text,
  status public.lead_status not null default 'new',
  assigned_user_id uuid references auth.users(id) on delete set null,
  internal_notes text,
  last_contacted_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint leads_name_not_blank check (length(btrim(name)) > 0),
  constraint leads_email_basic_format check (email ~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  constraint leads_user_count_positive check (user_count is null or user_count > 0),
  constraint leads_metadata_object check (jsonb_typeof(metadata) = 'object')
);

create table public.lead_notes (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid not null references public.leads(id) on delete cascade,
  author_id uuid references auth.users(id) on delete set null,
  body text not null,
  created_at timestamptz not null default now(),
  constraint lead_notes_body_not_blank check (length(btrim(body)) > 0)
);

create table public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint activity_logs_action_not_blank check (length(btrim(action)) > 0),
  constraint activity_logs_entity_type_not_blank check (length(btrim(entity_type)) > 0),
  constraint activity_logs_details_object check (jsonb_typeof(details) = 'object')
);

create index media_uploaded_by_idx on public.media(uploaded_by) where uploaded_by is not null;
create index media_public_created_idx on public.media(created_at desc) where is_public;
create index pages_parent_id_idx on public.pages(parent_id) where parent_id is not null;
create index pages_published_sort_idx on public.pages(sort_order) where status = 'published';
create index page_sections_page_sort_idx on public.page_sections(page_id, sort_order);
create index service_categories_parent_idx on public.service_categories(parent_id) where parent_id is not null;
create index services_category_idx on public.services(category_id) where category_id is not null;
create index services_published_sort_idx on public.services(sort_order) where status = 'published';
create index product_categories_parent_idx on public.product_categories(parent_id) where parent_id is not null;
create index products_published_sort_idx on public.products(sort_order) where status = 'published';
create index product_category_assignments_category_idx on public.product_category_assignments(category_id);
create index product_packages_product_sort_idx on public.product_packages(product_id, sort_order);
create index industries_published_sort_idx on public.industries(sort_order) where status = 'published';
create index projects_published_sort_idx on public.projects(sort_order) where status = 'published';
create index industry_services_service_idx on public.industry_services(service_id);
create index industry_products_product_idx on public.industry_products(product_id);
create index product_services_service_idx on public.product_services(service_id);
create index project_services_service_idx on public.project_services(service_id);
create index project_products_product_idx on public.project_products(product_id);
create index project_industries_industry_idx on public.project_industries(industry_id);
create index leads_status_created_idx on public.leads(status, created_at desc);
create index leads_assigned_created_idx on public.leads(assigned_user_id, created_at desc)
  where assigned_user_id is not null;
create index leads_email_idx on public.leads(lower(email));
create index lead_notes_lead_created_idx on public.lead_notes(lead_id, created_at desc);
create index activity_logs_entity_idx on public.activity_logs(entity_type, entity_id, created_at desc);
create index activity_logs_actor_idx on public.activity_logs(actor_id, created_at desc)
  where actor_id is not null;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'media', 'pages', 'page_sections', 'service_categories', 'services',
    'product_categories', 'products', 'product_category_assignments',
    'product_packages', 'industries', 'projects', 'industry_services',
    'industry_products', 'product_services', 'project_services',
    'project_products', 'project_industries', 'seo_metadata', 'site_settings',
    'leads', 'lead_notes', 'activity_logs'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('revoke all on table public.%I from anon, authenticated', table_name);
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'media', 'pages', 'page_sections', 'service_categories', 'services',
    'product_categories', 'products', 'product_category_assignments',
    'product_packages', 'industries', 'projects', 'industry_services',
    'industry_products', 'product_services', 'project_services',
    'project_products', 'project_industries', 'seo_metadata', 'site_settings'
  ]
  loop
    execute format('grant select on table public.%I to anon', table_name);
    execute format(
      'grant select, insert, update, delete on table public.%I to authenticated',
      table_name
    );
  end loop;

  grant insert on table public.leads to anon;
  grant select, insert, update, delete on table public.leads to authenticated;
  grant select, insert, update, delete on table public.lead_notes to authenticated;
  grant select, insert on table public.activity_logs to authenticated;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'media', 'pages', 'page_sections', 'service_categories', 'services',
    'product_categories', 'products', 'product_packages', 'industries',
    'projects', 'seo_metadata', 'site_settings', 'leads'
  ]
  loop
    execute format(
      'create trigger %I before update on public.%I for each row execute function private.set_updated_at()',
      table_name || '_set_updated_at',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'pages', 'service_categories', 'services', 'product_categories',
    'products', 'industries', 'projects'
  ]
  loop
    execute format(
      'create policy %I on public.%I for select to anon using (status = ''published'')',
      table_name || '_anon_read_published',
      table_name
    );
    execute format(
      'create policy %I on public.%I for select to authenticated using (status = ''published'' or (select private.has_permission(''content.manage'')))',
      table_name || '_authenticated_read',
      table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check ((select private.has_permission(''content.manage'')))',
      table_name || '_content_insert',
      table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using ((select private.has_permission(''content.manage''))) with check ((select private.has_permission(''content.manage'')))',
      table_name || '_content_update',
      table_name
    );
    execute format(
      'create policy %I on public.%I for delete to authenticated using ((select private.has_permission(''content.manage'')))',
      table_name || '_content_delete',
      table_name
    );
  end loop;
end;
$$;

create policy media_anon_read_public
on public.media for select to anon
using (is_public);

create policy media_authenticated_read
on public.media for select to authenticated
using (is_public or (select private.has_permission('media.manage')));

create policy media_manager_insert
on public.media for insert to authenticated
with check ((select private.has_permission('media.manage')));

create policy media_manager_update
on public.media for update to authenticated
using ((select private.has_permission('media.manage')))
with check ((select private.has_permission('media.manage')));

create policy media_manager_delete
on public.media for delete to authenticated
using ((select private.has_permission('media.manage')));

create policy page_sections_anon_read
on public.page_sections for select to anon
using (
  is_visible
  and exists (
    select 1 from public.pages page
    where page.id = page_id and page.status = 'published'
  )
);

create policy page_sections_authenticated_read
on public.page_sections for select to authenticated
using (
  (
    is_visible
    and exists (
      select 1 from public.pages page
      where page.id = page_id and page.status = 'published'
    )
  )
  or (select private.has_permission('content.manage'))
);

create policy page_sections_content_insert
on public.page_sections for insert to authenticated
with check ((select private.has_permission('content.manage')));

create policy page_sections_content_update
on public.page_sections for update to authenticated
using ((select private.has_permission('content.manage')))
with check ((select private.has_permission('content.manage')));

create policy page_sections_content_delete
on public.page_sections for delete to authenticated
using ((select private.has_permission('content.manage')));

create policy product_category_assignments_anon_read
on public.product_category_assignments for select to anon
using (
  exists (
    select 1 from public.products product
    where product.id = product_id and product.status = 'published'
  )
  and exists (
    select 1 from public.product_categories category
    where category.id = category_id and category.status = 'published'
  )
);

create policy product_category_assignments_authenticated_read
on public.product_category_assignments for select to authenticated
using (
  (
    exists (
      select 1 from public.products product
      where product.id = product_id and product.status = 'published'
    )
    and exists (
      select 1 from public.product_categories category
      where category.id = category_id and category.status = 'published'
    )
  )
  or (select private.has_permission('content.manage'))
);

create policy product_category_assignments_content_insert
on public.product_category_assignments for insert to authenticated
with check ((select private.has_permission('content.manage')));

create policy product_category_assignments_content_update
on public.product_category_assignments for update to authenticated
using ((select private.has_permission('content.manage')))
with check ((select private.has_permission('content.manage')));

create policy product_category_assignments_content_delete
on public.product_category_assignments for delete to authenticated
using ((select private.has_permission('content.manage')));

create policy product_packages_anon_read
on public.product_packages for select to anon
using (
  is_active
  and exists (
    select 1 from public.products product
    where product.id = product_id and product.status = 'published'
  )
);

create policy product_packages_authenticated_read
on public.product_packages for select to authenticated
using (
  (
    is_active
    and exists (
      select 1 from public.products product
      where product.id = product_id and product.status = 'published'
    )
  )
  or (select private.has_permission('content.manage'))
);

create policy product_packages_content_insert
on public.product_packages for insert to authenticated
with check ((select private.has_permission('content.manage')));

create policy product_packages_content_update
on public.product_packages for update to authenticated
using ((select private.has_permission('content.manage')))
with check ((select private.has_permission('content.manage')));

create policy product_packages_content_delete
on public.product_packages for delete to authenticated
using ((select private.has_permission('content.manage')));

do $$
declare
  relation_name text;
  left_table text;
  left_column text;
  right_table text;
  right_column text;
  relation_record record;
begin
  for relation_record in
    select * from (
      values
        ('industry_services', 'industries', 'industry_id', 'services', 'service_id'),
        ('industry_products', 'industries', 'industry_id', 'products', 'product_id'),
        ('product_services', 'products', 'product_id', 'services', 'service_id'),
        ('project_services', 'projects', 'project_id', 'services', 'service_id'),
        ('project_products', 'projects', 'project_id', 'products', 'product_id'),
        ('project_industries', 'projects', 'project_id', 'industries', 'industry_id')
    ) as relationships(relation_name, left_table, left_column, right_table, right_column)
  loop
    relation_name := relation_record.relation_name;
    left_table := relation_record.left_table;
    left_column := relation_record.left_column;
    right_table := relation_record.right_table;
    right_column := relation_record.right_column;

    execute format(
      'create policy %I on public.%I for select to anon using (exists (select 1 from public.%I left_item where left_item.id = %I and left_item.status = ''published'') and exists (select 1 from public.%I right_item where right_item.id = %I and right_item.status = ''published''))',
      relation_name || '_anon_read', relation_name, left_table, left_column,
      right_table, right_column
    );
    execute format(
      'create policy %I on public.%I for select to authenticated using ((exists (select 1 from public.%I left_item where left_item.id = %I and left_item.status = ''published'') and exists (select 1 from public.%I right_item where right_item.id = %I and right_item.status = ''published'')) or (select private.has_permission(''content.manage'')))',
      relation_name || '_authenticated_read', relation_name, left_table, left_column,
      right_table, right_column
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check ((select private.has_permission(''content.manage'')))',
      relation_name || '_content_insert', relation_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using ((select private.has_permission(''content.manage''))) with check ((select private.has_permission(''content.manage'')))',
      relation_name || '_content_update', relation_name
    );
    execute format(
      'create policy %I on public.%I for delete to authenticated using ((select private.has_permission(''content.manage'')))',
      relation_name || '_content_delete', relation_name
    );
  end loop;
end;
$$;

create policy seo_metadata_anon_read
on public.seo_metadata for select to anon
using (
  (page_id is not null and exists (
    select 1 from public.pages item where item.id = page_id and item.status = 'published'
  ))
  or (service_id is not null and exists (
    select 1 from public.services item where item.id = service_id and item.status = 'published'
  ))
  or (product_id is not null and exists (
    select 1 from public.products item where item.id = product_id and item.status = 'published'
  ))
  or (industry_id is not null and exists (
    select 1 from public.industries item where item.id = industry_id and item.status = 'published'
  ))
  or (project_id is not null and exists (
    select 1 from public.projects item where item.id = project_id and item.status = 'published'
  ))
);

create policy seo_metadata_authenticated_read
on public.seo_metadata for select to authenticated
using (
  (select private.has_permission('seo.manage'))
  or (page_id is not null and exists (
    select 1 from public.pages item where item.id = page_id and item.status = 'published'
  ))
  or (service_id is not null and exists (
    select 1 from public.services item where item.id = service_id and item.status = 'published'
  ))
  or (product_id is not null and exists (
    select 1 from public.products item where item.id = product_id and item.status = 'published'
  ))
  or (industry_id is not null and exists (
    select 1 from public.industries item where item.id = industry_id and item.status = 'published'
  ))
  or (project_id is not null and exists (
    select 1 from public.projects item where item.id = project_id and item.status = 'published'
  ))
);

create policy seo_metadata_manager_insert
on public.seo_metadata for insert to authenticated
with check ((select private.has_permission('seo.manage')));

create policy seo_metadata_manager_update
on public.seo_metadata for update to authenticated
using ((select private.has_permission('seo.manage')))
with check ((select private.has_permission('seo.manage')));

create policy seo_metadata_manager_delete
on public.seo_metadata for delete to authenticated
using ((select private.has_permission('seo.manage')));

create policy site_settings_anon_read
on public.site_settings for select to anon
using (is_public);

create policy site_settings_authenticated_read
on public.site_settings for select to authenticated
using (is_public or (select private.has_permission('settings.manage')));

create policy site_settings_manager_insert
on public.site_settings for insert to authenticated
with check ((select private.has_permission('settings.manage')));

create policy site_settings_manager_update
on public.site_settings for update to authenticated
using ((select private.has_permission('settings.manage')))
with check ((select private.has_permission('settings.manage')));

create policy site_settings_manager_delete
on public.site_settings for delete to authenticated
using ((select private.has_permission('settings.manage')));

create policy leads_anon_submit
on public.leads for insert to anon
with check (
  status = 'new'
  and assigned_user_id is null
  and internal_notes is null
  and last_contacted_at is null
);

create policy leads_authenticated_submit_or_manage
on public.leads for insert to authenticated
with check (
  (
    status = 'new'
    and assigned_user_id is null
    and internal_notes is null
    and last_contacted_at is null
  )
  or (select private.has_permission('leads.manage'))
);

create policy leads_manager_read
on public.leads for select to authenticated
using ((select private.has_permission('leads.manage')));

create policy leads_manager_update
on public.leads for update to authenticated
using ((select private.has_permission('leads.manage')))
with check ((select private.has_permission('leads.manage')));

create policy leads_manager_delete
on public.leads for delete to authenticated
using ((select private.has_permission('leads.manage')));

create policy lead_notes_manager_read
on public.lead_notes for select to authenticated
using ((select private.has_permission('leads.manage')));

create policy lead_notes_manager_insert
on public.lead_notes for insert to authenticated
with check ((select private.has_permission('leads.manage')));

create policy lead_notes_manager_update
on public.lead_notes for update to authenticated
using ((select private.has_permission('leads.manage')))
with check ((select private.has_permission('leads.manage')));

create policy lead_notes_manager_delete
on public.lead_notes for delete to authenticated
using ((select private.has_permission('leads.manage')));

create policy activity_logs_admin_read
on public.activity_logs for select to authenticated
using ((select private.is_admin()));

create policy activity_logs_admin_insert
on public.activity_logs for insert to authenticated
with check ((select private.is_admin()));
