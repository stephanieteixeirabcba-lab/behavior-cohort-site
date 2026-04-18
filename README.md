# Behavior Therapy Cohort Site

A static website for running your international behavior therapy cohort, hosted free on GitHub Pages.

## What's in here

```
/
├── index.html              Home page
├── syllabus.html           Course overview + 10-meeting schedule
├── resources.html          Reference library
├── grades.html             Info on private progress sheets
├── modules/
│   ├── index.html          Module index
│   └── module-01.html      Module template (duplicate for modules 2–10)
└── assets/css/style.css    Shared stylesheet
```

## How to deploy to GitHub Pages

1. Create a new GitHub repository (public or private — Pages is free for public; paid plans allow private).
2. Push this whole folder as the repository contents.
3. In the repo: **Settings → Pages → Source: Deploy from branch → `main` / `root`**.
4. Your site will be live at `https://<your-username>.github.io/<repo-name>/` within a couple of minutes.
5. Optional: buy a custom domain and point it at GitHub Pages.

## Before launch — things to customize

Search-and-replace across the whole folder for each of these:

- `your-email@example.com` → your real email
- `International cohort · 2026` → update if needed
- Meeting dates in `syllabus.html` → your real dates once confirmed
- The `href="#"` on **"Submit assignment"** buttons → your Google Form URLs
- The `href="#"` on **"Open discussions"** → your GitHub Discussions URL
- The empty video placeholder in `modules/module-01.html` → your unlisted YouTube/Vimeo embed

## How to build out the remaining modules

For each new module (2 through 10):
1. Copy `modules/module-01.html` to `modules/module-02.html`, etc.
2. Update the title, eyebrow ("Module 02 · For Meeting 2"), H1, lead paragraph.
3. Replace the readings, lecture, and homework sections with that module's content.
4. In `modules/index.html`, remove `style="opacity:0.55;"` from that module's card and change the `<div class="card">` to `<a class="card" href="module-02.html">`, and update "Coming soon" to a real open date.

Keep the unreleased modules dimmed until their open date — that's a deliberate signal to participants.

## The supporting stack (free)

- **Homework submissions:** Google Forms — one form per homework assignment. Responses flow into a Google Sheet you control.
- **Grades / progress:** One Google Sheet per participant, shared only with them. You maintain a master sheet.
- **Discussion:** GitHub Discussions on this same repo (Settings → enable Discussions). Threaded, searchable, professional.
- **Meeting video:** Zoom / Google Meet — email the link before each meeting.
- **Video lectures:** Unlisted YouTube videos embed cleanly into module pages.

## Security notes

This is a public static website. Do not put anything on it that should be private:
- No client information, even de-identified case studies
- No participant names, emails, or personal details
- No homework submissions (those go to Google Forms, which are permissioned)
- No grades (those live in private Google Sheets)

The `/grades.html` page is intentionally just an explainer — real grade data lives in the private per-participant Google Sheets.

## Running the site locally to preview

Any static file server works. The simplest:

```bash
cd cohort-site
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

## Timeline to May launch

- **This week:** Deploy to GitHub Pages, customize the placeholders, set up your Google Forms for Module 1 homework, create per-participant Sheets.
- **Next week:** Write and record the Module 1 lecture, populate Module 1 readings, confirm meeting dates.
- **Week before launch:** Send welcome email with site link, first meeting link, and progress sheet link.
- **Ongoing:** Open one module at a time, ~1 week before each meeting.

You don't need all 10 modules ready on day one. Build as you go.
