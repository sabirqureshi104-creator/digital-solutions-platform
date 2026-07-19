-- Add covering indexes for foreign keys reported by the Supabase database linter.
-- These indexes improve joins and parent-row updates/deletes as the tables grow.

create index if not exists industries_hero_media_id_idx
  on public.industries (hero_media_id);

create index if not exists lead_notes_author_id_idx
  on public.lead_notes (author_id);

create index if not exists leads_attachment_media_id_idx
  on public.leads (attachment_media_id);

create index if not exists leads_industry_id_idx
  on public.leads (industry_id);

create index if not exists pages_created_by_idx
  on public.pages (created_by);

create index if not exists pages_updated_by_idx
  on public.pages (updated_by);

create index if not exists products_featured_media_id_idx
  on public.products (featured_media_id);

create index if not exists projects_hero_media_id_idx
  on public.projects (hero_media_id);

create index if not exists seo_metadata_social_media_id_idx
  on public.seo_metadata (social_media_id);

create index if not exists services_hero_media_id_idx
  on public.services (hero_media_id);

create index if not exists site_settings_updated_by_idx
  on public.site_settings (updated_by);