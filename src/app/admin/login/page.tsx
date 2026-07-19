import type { Metadata } from "next";
import Link from "next/link";

import { login } from "../actions";

export const metadata: Metadata = {
  title: "Admin sign in | Digital Solutions Platform",
  description: "Secure administrator access for Digital Solutions Platform.",
};

type LoginPageProps = {
  searchParams: Promise<{
    error?: string;
  }>;
};

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const { error } = await searchParams;

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#070a12] px-6 py-16 text-white">
      <div
        aria-hidden="true"
        className="absolute inset-0 bg-[radial-gradient(circle_at_20%_15%,rgba(34,211,238,0.16),transparent_34%),radial-gradient(circle_at_85%_80%,rgba(99,102,241,0.18),transparent_38%)]"
      />
      <div
        aria-hidden="true"
        className="absolute inset-0 opacity-20 [background-image:linear-gradient(rgba(255,255,255,0.06)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.06)_1px,transparent_1px)] [background-size:48px_48px]"
      />

      <section className="relative w-full max-w-md rounded-3xl border border-white/10 bg-white/[0.06] p-8 shadow-2xl shadow-cyan-950/30 backdrop-blur-xl sm:p-10">
        <div className="mb-8">
          <p className="mb-4 font-mono text-xs uppercase tracking-[0.28em] text-cyan-300">
            Secure control centre
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">Administrator sign in</h1>
          <p className="mt-3 text-sm leading-6 text-slate-400">
            Manage website content, enquiries, media, and platform settings.
          </p>
        </div>

        {error ? (
          <div
            role="alert"
            className="mb-6 rounded-2xl border border-rose-400/20 bg-rose-400/10 px-4 py-3 text-sm text-rose-200"
          >
            {error}
          </div>
        ) : null}

        <form action={login} className="space-y-5">
          <label className="block">
            <span className="mb-2 block text-sm font-medium text-slate-200">
              Email address
            </span>
            <input
              type="email"
              name="email"
              autoComplete="email"
              required
              className="h-12 w-full rounded-xl border border-white/10 bg-black/20 px-4 text-sm text-white outline-none transition placeholder:text-slate-600 focus:border-cyan-300/60 focus:ring-4 focus:ring-cyan-400/10"
              placeholder="you@company.com"
            />
          </label>

          <label className="block">
            <span className="mb-2 block text-sm font-medium text-slate-200">
              Password
            </span>
            <input
              type="password"
              name="password"
              autoComplete="current-password"
              required
              className="h-12 w-full rounded-xl border border-white/10 bg-black/20 px-4 text-sm text-white outline-none transition placeholder:text-slate-600 focus:border-cyan-300/60 focus:ring-4 focus:ring-cyan-400/10"
              placeholder="Enter your password"
            />
          </label>

          <button
            type="submit"
            className="flex h-12 w-full items-center justify-center rounded-xl bg-cyan-300 px-5 text-sm font-semibold text-slate-950 transition hover:bg-cyan-200 focus:outline-none focus:ring-4 focus:ring-cyan-300/20"
          >
            Sign in securely
          </button>
        </form>

        <div className="mt-8 border-t border-white/10 pt-6 text-center">
          <Link
            href="/"
            className="text-sm text-slate-400 transition hover:text-cyan-200"
          >
            Return to the public website
          </Link>
        </div>
      </section>
    </main>
  );
}