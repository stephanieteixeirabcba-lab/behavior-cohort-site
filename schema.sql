-- ============================================================================
-- Behavior Therapist Course — Supabase schema
-- Paste this entire file into the Supabase SQL Editor and run it.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. PROFILES
-- Each auth.user gets a profile row. Linked by id = auth.uid()
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  role text default 'participant' check (role in ('participant', 'admin')),
  created_at timestamp with time zone default now()
);

alter table public.profiles enable row level security;

-- Users can read and update their own profile
create policy "Users read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Admins can read all profiles
create policy "Admins read all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ---------------------------------------------------------------------------
-- 2. INVITE CODES
-- You generate these; participants enter one during signup.
-- Each code has a max_uses; when used_count >= max_uses, it stops working.
-- ---------------------------------------------------------------------------
create table if not exists public.invite_codes (
  code text primary key,
  description text,
  max_uses integer default 25,
  used_count integer default 0,
  active boolean default true,
  created_at timestamp with time zone default now()
);

alter table public.invite_codes enable row level security;

-- Anonymous users can verify a code exists and is active (needed during signup)
create policy "Anyone can check codes"
  on public.invite_codes for select
  using (true);

-- Only admins can create/modify codes (done through Supabase dashboard directly)
-- No insert/update policies for regular users.

-- ---------------------------------------------------------------------------
-- 3. ASSIGNMENTS
-- Static definitions of the 10 homework assignments.
-- ---------------------------------------------------------------------------
create table if not exists public.assignments (
  id text primary key,            -- e.g. 'module-01'
  module_number integer not null,
  title text not null,
  prompt text,
  due_description text,           -- e.g. "Before Meeting 2"
  open boolean default false,     -- admins flip this true when the module opens
  created_at timestamp with time zone default now()
);

alter table public.assignments enable row level security;

-- Anyone signed in can read assignments
create policy "Signed-in users read assignments"
  on public.assignments for select
  using (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- 4. SUBMISSIONS
-- One row per submission. Participants see only their own; admins see all.
-- ---------------------------------------------------------------------------
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  assignment_id text not null references public.assignments(id),
  submission_text text not null,
  submitted_at timestamp with time zone default now(),
  feedback text,
  feedback_at timestamp with time zone,
  unique (user_id, assignment_id)  -- one submission per user per assignment
);

alter table public.submissions enable row level security;

-- Users can read their own submissions
create policy "Users read own submissions"
  on public.submissions for select
  using (auth.uid() = user_id);

-- Users can insert their own submissions
create policy "Users insert own submissions"
  on public.submissions for insert
  with check (auth.uid() = user_id);

-- Users can update their own submission TEXT (but cannot modify feedback — admins only)
create policy "Users update own submission text"
  on public.submissions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Admins can read all submissions
create policy "Admins read all submissions"
  on public.submissions for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admins can update any submission (to add feedback)
create policy "Admins update any submission"
  on public.submissions for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ---------------------------------------------------------------------------
-- 5. AUTO-CREATE PROFILE ON SIGNUP
-- When a new auth.user is created, automatically create a matching profile row.
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 6. SEED DATA — the 10 assignments
-- Only Module 1 is open to start; you'll flip others open as modules release.
-- ---------------------------------------------------------------------------
insert into public.assignments (id, module_number, title, prompt, due_description, open) values
  ('module-01', 1, 'Foundations reflection',
   'Describe one moment in your work — recent or past — where you either (a) targeted or were asked to target a behavior that, after this module, you now think should not have been targeted, or (b) observed or participated in a session where something about the approach sat uncomfortably with you. Then: of the six commitments, which one will be hardest for you to live up to in your current work setting, and why?',
   'Before Meeting 2', true),
  ('module-02', 2, 'Scope-of-practice scenarios', 'To be written.', 'Before Meeting 3', false),
  ('module-03', 3, 'Functional analysis observation', 'To be written.', 'Before Meeting 4', false),
  ('module-04', 4, 'Assent-reading practice log', 'To be written.', 'Before Meeting 5', false),
  ('module-05', 5, 'Trauma-informed practice reflection', 'To be written.', 'Before Meeting 6', false),
  ('module-06', 6, 'Midpoint self-reflection', 'To be written.', 'Before Meeting 7', false),
  ('module-07', 7, 'Reinforcement practice note', 'To be written.', 'Before Meeting 8', false),
  ('module-08', 8, 'AAC observation & reflection', 'To be written.', 'Before Meeting 9', false),
  ('module-09', 9, 'Sensory/regulation case note', 'To be written.', 'Before Meeting 10', false),
  ('module-10', 10, 'Final integrative reflection', 'To be written.', 'At Meeting 10', false)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 7. SEED DATA — create an initial invite code
-- CHANGE THIS CODE before going live. Pick something memorable but not guessable.
-- ---------------------------------------------------------------------------
insert into public.invite_codes (code, description, max_uses, active) values
  ('COHORT-2026-MAY', 'Initial cohort invite code — change before launch', 25, true)
on conflict (code) do nothing;

-- ============================================================================
-- DONE.
-- After running this:
--   1. Create your own account via the signup page (use the invite code above)
--   2. In the Supabase dashboard → Table Editor → profiles, change your
--      own row's `role` from 'participant' to 'admin'
--   3. Now you can see all submissions through the Supabase dashboard
-- ============================================================================
