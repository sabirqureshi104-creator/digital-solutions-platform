"use server";

import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";

function redirectToLogin(message: string): never {
  redirect(`/admin/login?error=${encodeURIComponent(message)}`);
}

export async function login(formData: FormData) {
  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    redirectToLogin("Enter both your email address and password.");
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error || !data.user) {
    redirectToLogin("The email address or password is incorrect.");
  }

  const { data: adminRole, error: roleError } = await supabase
    .from("user_roles")
    .select("role_id, roles!inner(slug)")
    .eq("user_id", data.user.id)
    .eq("roles.slug", "admin")
    .maybeSingle();

  if (roleError || !adminRole) {
    await supabase.auth.signOut();
    redirectToLogin("This account does not have administrator access.");
  }

  redirect("/admin");
}

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/admin/login");
}
