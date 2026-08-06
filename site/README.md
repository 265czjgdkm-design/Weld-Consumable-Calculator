# Marketing Site

Landing page for Weld Consumable Calculator (`index.html`, `privacy.html`) plus
the real calculator running as a Flutter web build under `app/`.

`app/` is a build artifact — it is git-ignored and must be regenerated whenever
`lib/` changes:

```bash
flutter build web --release --base-href /app/ -o site/app
```

## Preview locally

```bash
cd site
python3 -m http.server 8080
```

Then open http://localhost:8080 — "Open the calculator" / the hero mockup /
the pricing card all link to the live app at `/app/`.

## Deploy (pick one)

- **GitHub Pages**: Settings → Pages → deploy from branch, folder `/site`. Rebuild
  `site/app` before every deploy (see above) since it's not committed.
- **Netlify**: drag-and-drop the `site/` folder onto app.netlify.com/drop, after
  rebuilding `site/app`.
- **Vercel**: `vercel deploy site/` from the repo root, after rebuilding `site/app`.

For CI, add a build step that runs the `flutter build web` command above before
the static-site deploy step.

## Before publishing

- Replace `PLACEHOLDER@EXAMPLE.COM` in `privacy.html` **and** `terms.html` with a
  real contact email.
- Once the mobile app is live, swap the "Use it now in your browser" / notify
  form in the pricing card for the real App Store badge/link.
- The deployed `privacy.html` URL is what goes into App Store Connect's Privacy
  Policy URL field.
- **Waitlist form**: the pricing card's notify form (inside `#pricing` /
  `#notify` in `index.html`) posts to
  `https://formspree.io/f/YOUR_FORM_ID`. Sign up free at formspree.io, create a
  form, and replace `YOUR_FORM_ID` in `index.html` (the `<form action="...">`
  attribute) with the ID Formspree gives you. Submissions then land in your
  Formspree inbox/email — no other setup needed.
