import type { Metadata } from "next";
import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";
import { logout } from "./actions";

export const metadata: Metadata = {
  title: "Admin dashboard | Digital Solutions Platform",
  description: "Digital Solutions Platform administration dashboard.",
};

export default async function AdminDashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/admin/login");
  }

  const { data: adminRole } = await supabase
    .from("user_roles")
    .select("role_id, roles!inner(slug)")
    .eq("user_id", user.id)
    .eq("roles.slug", "admin")
    .maybeSingle();

  if (!adminRole) {
    redirect(
      "/admin/login?error=This%20account%20does%20not%20have%20administrator%20access."
    );
  }

  const [{ data: profile }, pages, leads, media] = await Promise.all([
    supabase
      .from("profiles")
      .select("display_name")
      .eq("id", user.id)
      .maybeSingle(),
    supabase.from("pages").select("*", { count: "exact", head: true }),
    supabase.from("leads").select("*", { count: "exact", head: true }),
    supabase.from("media").select("*", { count: "exact", head: true }),
  ]);

  const displayName = profile?.display_name ?? user.email ?? "Administrator";
  const metrics = [
    { label: "Content pages", value: pages.count ?? 0 },
    { label: "Customer enquiries", value: leads.count ?? 0 },
    { label: "Media assets", value: media.count ?? 0 },
  ];

  return (
    <main className="min-h-screen bg-[#070a12] px-6 py-8 text-white sm:px-10 lg:px-16">
      <div className="mx-auto max-w-7xl">
        <header className="flex flex-col gap-6 border-b border-white/10 pb-8 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="font-mono text-xs uppercase tracking-[0.25em] text-cyan-300">
              Digital Solutions Platform
            </p>
            <h1 className="mt-3 text-3xl font-semibold tracking-tight">
              Administration dashboard
            </h1>
          </div>

          <form action={logout}>
            <button
              type="submit"
              className="rounded-xl border border-white/10 bg-white/[0.05] px-4 py-2.5 text-sm text-slate-200 transition hover:border-white/20 hover:bg-white/10"
            >
              Sign out
            </button>
          </form>
        </header>

        <section className="py-10">
          <p className="text-sm text-slate-400">Signed in as</p>
          <h2 className="mt-2 text-2xl font-medium">{displayName}</h2>

          <div className="mt-8 grid gap-4 md:grid-cols-3">
            {metrics.map((metric) => (
              <article
                key={metric.label}
                className="rounded-2xl border border-white/10 bg-white/[0.05] p-6"
              >
                <p className="text-sm text-slate-400">{metric.label}</p>
                <p className="mt-4 font-mono text-4xl font-semibold text-cyan-200">
                  {metric.value}
                </p>
              </article>
            ))}
          </div>

          <div className="mt-8 rounded-2xl border border-cyan-300/15 bg-cyan-300/[0.06] p-6">
            <p className="font-medium text-cyan-100">Authentication is working.</p>
            <p className="mt-2 max-w-2xl text-sm leading-6 text-slate-400">
              This protected dashboard confirms the Supabase session, administrator
              role, row-level security policies, and live database connection.
            </p>
          </div>
        </section>
      </div>
    </main>
  );
}
