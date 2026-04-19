# Behavior Therapist Course — Site

Static site for the Neurodiversity-Affirming ABA cohort, hosted on GitHub Pages, with Supabase-powered authentication and homework submissions.

## Architecture

- **Frontend:** Static HTML/CSS/JS hosted on GitHub Pages (free)
- **Auth & database:** Supabase (free tier)
- **Discussions:** GitHub Discussions (enabled on this repo)
- **Meeting links:** Distributed by email, not posted on site

## What's in this folder

```
/
├── index.html              Home page
├── syllabus.html           Course overview + schedule
├── resources.html          Reference library
├── login.html              Login / signup
├── grades.html             Participant's personal progress view
├── modules/
│   ├── index.html          Module index
│   └── module-01.html      Module 1 (with Supabase-connected submission form)
├── assets/
│   ├── css/style.css       Shared stylesheet
│   └── js/
│       ├── supabase-config.js   ← EDIT THIS with your Supabase keys
│       └── auth.js              Shared auth utilities
└── supabase/
    └── schema.sql          Run this in your Supabase SQL Editor
```

## Setup — in order

### Step 1 — Create the Supabase project

1. Sign up at https://supabase.com (use GitHub login for ease)
2. Click "New project"
3. Name: `behavior-therapist-course`
4. Database password: let it generate one and save it safely
5. Region: pick the closest to you or your cohort
6. Pricing plan: Free
7. Wait ~2 minutes for provisioning

### Step 2 — Run the schema

1. In your Supabase project, click **SQL Editor** (left sidebar)
2. Click "New query"
3. Open `supabase/schema.sql` from this repo, copy the whole file
4. Paste into the SQL Editor, click "Run"
5. You should see "Success" with no errors

This creates: `profiles`, `invite_codes`, `assignments`, `submissions` tables, plus Row-Level Security policies that ensure each user sees only their own data.

### Step 3 — Grab your API keys

1. In Supabase, click the **gear icon** (Settings) in the bottom-left
2. Click **API**
3. You need two values:
   - **Project URL** (looks like `https://abcd1234.supabase.co`)
   - **anon / public key** (a long string starting with `eyJ...`)
4. Open `assets/js/supabase-config.js` in this repo
5. Paste both values in the marked places
6. The `anon` key is safe to commit — Row-Level Security in the schema is what actually protects your data

### Step 4 — Configure auth settings in Supabase

1. In Supabase, click **Authentication** (left sidebar) → **Providers**
2. Make sure **Email** is enabled (it is by default)
3. Go to **Authentication** → **URL Configuration**
4. Set **Site URL** to your GitHub Pages URL (e.g. `https://yourname.github.io/your-repo/`)
5. Under **Email Auth**, decide whether you want email confirmation. For a small cohort, you can turn "Confirm email" OFF for simpler signup (Authentication → Providers → Email → uncheck "Confirm email"). Trade-off: without confirmation, anyone who knows an invite code can create an account without a real email.

### Step 5 — Change the invite code

The schema creates a default invite code: `COHORT-2026-MAY`

Change this before sharing with participants:

1. Supabase → **Table Editor** → `invite_codes`
2. Either edit the existing row or insert a new one:
   - `code`: pick something memorable, like `MAY2026-WELCOME` (uppercase, no spaces)
   - `max_uses`: 25 (or however big your cohort is)
   - `active`: true
3. Share this code privately with enrolled participants

### Step 6 — Create your admin account

1. Go to your (deployed) site → click "Log in" → switch to signup tab
2. Sign up with your real email, using your invite code
3. Once logged in, go to Supabase → **Table Editor** → `profiles`
4. Find your row, change `role` from `participant` to `admin`
5. Save. You can now see all submissions across all participants.

### Step 7 — Deploy to GitHub Pages

1. Create a new repo on GitHub (public — needed for free Pages)
2. Push everything in this folder to the repo root
3. Repo → Settings → Pages → Source: "Deploy from a branch" → Branch: `main` / root → Save
4. Wait ~1 minute. Your site is live at `https://yourname.github.io/your-repo/`

### Step 8 — Enable GitHub Discussions

Repo → Settings → scroll to **Features** → check **Discussions** → a Discussions tab appears.

Set up categories: Announcements, Questions, Case discussions, Readings. Copy the Discussions URL and paste it into `resources.html` (the "Open discussions" button currently has `href="#"`).

## Reviewing submissions as the instructor

Once your role is `admin`, you have two options:

**Option A — Use Supabase dashboard (simpler for v1)**
- Supabase → Table Editor → `submissions`
- See all submissions across all users
- To leave feedback: click a row, fill in `feedback` and set `feedback_at` to now
- Participant sees your feedback on their `grades.html`

**Option B — Build an admin page on the site (later)**
Can be added to a future version if the dashboard workflow gets tedious.

## Customizing the content

- **Meeting dates** in `syllabus.html` — update as you confirm them
- **Recorded lecture** in `modules/module-01.html` — replace the video placeholder with your YouTube/Vimeo embed
- **Modules 2–10** — copy `modules/module-01.html` to `module-02.html` etc., update the assignment ID in the JavaScript (`const ASSIGNMENT_ID = 'module-02';`), rewrite the content, and flip `open = true` in the `assignments` table in Supabase when ready.

## Running locally to test

```bash
python3 -m http.server 8000
```
Then open http://localhost:8000

Note: Supabase auth won't work from `file://` URLs — you need a local server.

## Security notes

- `supabase-config.js` is safe to commit publicly — the anon key is designed to be public
- Row-Level Security (set up by `schema.sql`) is what actually protects data
- Invite codes are a soft barrier — they prevent strangers from signing up but someone who has the code can share it. For a small professional cohort this is fine.
- No client PHI should ever be entered into this system — make this a ground rule with participants
- If you ever suspect the anon key is being abused, you can rotate it in Supabase Settings → API → "Generate new anon key"
