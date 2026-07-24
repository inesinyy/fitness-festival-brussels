# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page static site for FFB (Fitness Festival Brussels), a fitness event landing page. There is no build system, no package manager, and no framework — everything lives in one file: [index.html](index.html). CSS is inline in a `<style>` block, JS is inline in a `<script>` block at the bottom, and the page content is in French.

**Site status:** the 2026 edition (11 juillet) has already happened, so the site is currently in "retrospective" mode rather than "buy tickets" mode — hero, ticker, and the programme intro are written in the past tense, and the `#billetterie` section is disabled (see below) since registrations for edition 2 aren't open yet.

Assets referenced from `index.html`: [logo.jpg](logo.jpg) (resized/compressed for its ~38px nav display size), [hero.jpg](hero.jpg) (hero background image, `.hero-video` class, recompressed from a source PNG to keep page weight down), per-coach photos at repo root (`coach-<name>.jpg`, e.g. [coach-bin.jpg](coach-bin.jpg)) referenced by filename in each `.coach-card`, sponsor logos (`sponsor-<name>.jpg`) in the Partenaires section, retrospective gallery photos (`retro-1.jpg` … `retro-10.jpg`, curated stills from the event, kept in full color unlike the grayscale coach/sponsor treatment), and favicon files (`favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png`, all cropped from the logo's "FFB" mark). The [assets/](assets/) directory holds source/working copies of these images (higher-res originals, including the full `FFB_ (NNN).JPG` event photo dump the retrospective picks were sourced from, plus `hero.mp4`) and is not itself referenced by `index.html` — treat it as a staging folder, not a served path.

## Running locally

There's no npm/build step. Serve the directory root with a static file server and open `http://localhost:3000`:

```bash
python3 server.py       # serves cwd on port 3000 via http.server
```

or

```bash
perl server.pl [port]   # defaults to port 3000, forking mime-type-aware server
```

Either works; `server.py` is simpler and preferred for quick checks. `.claude/launch.json` also defines a Perl-based inline launch config for the same purpose.

## Deployment

Deployed via GitHub Pages directly from the `main` branch (no CI workflow, no CNAME). Pushing to `main` and forcing a redeploy is done with an empty/chore commit (see git history) since Pages otherwise deploys automatically on push.

## Architecture of index.html

The page is one long scrolling document composed of stacked sections, all anchored by nav links (`#retrospective`, `#apropos`, `#programme`, `#coachs`, `#partenaires`):

- **Hero** — full-bleed background image (`.hero-video` class name is legacy from when a video was used; it now points at `hero.jpg`) with a scroll-based parallax effect driven by inline JS. Height is `max(calc(100vh - 126px), 420px)` — 126px is the combined fixed height of the sticky nav (67px) and the ticker below it (59px), so the ticker's bottom edge lands on the fold.
- **Ticker** — an infinite auto-scrolling marquee of event facts; built by duplicating the same set of `.ticker-item`s twice in markup for a seamless CSS `@keyframes` loop. No margin below it — the next section's content (the À propos photo panel) sits flush against it.
- **À propos (`#apropos`)** — two full-bleed panels (`.apropos-panels`, edge-to-edge via `width:100vw` + negative margins, no gap between them, square corners): a photo on one side, and a solid-yellow panel on the other containing the eyebrow, the `<h2>Le concept</h2>`, and the intro prose. On mobile the panels stack with the text panel first (`order` swap in the `max-width:720px` query — the photo stays second in the DOM). Below the panels, `.apropos-timeline` renders the 4-step "how a day at FFB unfolds" summary as a horizontal timeline (connecting line via `::before`, numbered `.timeline-dot` circles with a `box-shadow` "hole punch" so the line appears to pass behind them) that collapses to a vertical timeline on mobile.
- **Programme (`#programme`)** — no longer its own top-level section: it's a `<div id="programme" class="wrap">` nested inside `#retrospective`, right after the photo carousel, heading renamed "Programme de l'édition précédente". Still an accordion timeline (`.t-item` / `.t-row` / `.t-desc`); each course row has a fixed `id` (e.g. `#cours-body-pump`, `#cours-body-combat`) linked from the coach tags below — clicking a coach's course tag opens and scrolls to that course. The nav's "Programme" link still works since `#programme` is a real anchor, just nested.
- **Billetterie (`#billetterie`)** and **Lieu (`#lieu`)** — currently **disabled** (registrations for edition 2 aren't open, and no venue is confirmed yet): both sections are wrapped in HTML comments, with their nav links removed/commented and their CTAs (nav "Billets", final-cta "Réserver ma place") swapped for an Instagram "Suivre l'actu" link. Each commented block has an inline note on exactly what to restore and where — search for "décommenter" in `index.html` to find all three spots per section.
- **Rétrospective (`#retrospective`)** — photo carousel of the past edition (same infinite-loop JS as Coachs, see `initCarousel`) with plain photo cards (`.retro-card`, ~75vw wide on desktop) instead of coach profile cards, followed by the nested Programme block described above.
- **Coachs (`#coachs`)** — an infinite-loop carousel built by JS: the original card set is cloned twice (once prepended, once appended) to fake infinite scrolling, then the track is jumped to the middle set on load. Coach `.coach-tag` links point to `#cours-*` anchors and are wired via event delegation on the track (so it works for both original and cloned cards). Coaches without a photo yet use a `.coach-initials` placeholder (two-letter initials) inside `.coach-photo-wrap` instead of an `<img>`.
- **Carousel JS** — both Coachs and Rétrospective share one `initCarousel(track, btnPrev, btnNext, cardSelector)` function (bottom of the inline `<script>`); adding a third carousel means adding a new `.carousel-btn` pair + track markup and one more `initCarousel(...)` call, not duplicating the carousel logic.
- **Partenaires (`#partenaires`)** — sponsor logos in square `.partner-slot` cards, `object-fit: cover` so each logo fills its card edge-to-edge; grayscale by default with a color reveal on hover, matching the coach-photo treatment.
- **Section headings** — plain cream-on-black `<h2>` everywhere (the original look) **except** the final-cta heading ("On se retrouve pour l'édition 2 ?"), which gets a decorative `.h2-tape` treatment built by JS: a full-bleed (edge-to-edge, `getBoundingClientRect()`-corrected margin — see `fitFullBleed()`) yellow rotated banner reusing the `.warning-tape` visual language, with a subtle scroll-linked parallax (`translateY` driven by the element's viewport position). The real `<h2>` stays in the DOM as `.sr-only` for accessibility/SEO. If asked to apply this tape look to other headings again, wire them back into the `document.querySelectorAll(...)` selector in that IIFE.
- **Scroll reveal** — any element with class `.reveal` (optionally `data-delay="1|2|3"` for staggered timing) fades/slides in via a single shared `IntersectionObserver`, respecting `prefers-reduced-motion`.

## Conventions to preserve when editing

- Keep everything self-contained in `index.html` — no build step exists to bundle separate CSS/JS files.
- Course anchor IDs (`#cours-*`) and coach tag `href`s must stay in sync; adding/renaming a course in the programme section requires updating any coach tags that reference it.
- New animated-in elements should get the `.reveal` class (and `data-delay` if staggering within the same section) to match existing scroll-in behavior.
- Color/spacing tokens are CSS custom properties defined in `:root` (`--black`, `--cream`, `--yellow`, `--red`, `--green`, `--radius`, `--shadow*`) — reuse these rather than hardcoding new colors.
- Full-bleed elements nested in constrained/flex containers (`.wrap`, `.coachs-header`) can't reliably use the plain CSS `width:100vw; margin-left:calc(50% - 50vw)` trick if an ancestor isn't itself centered on the viewport (see `fitFullBleed()` in the JS) — measure and correct with `getBoundingClientRect()` in that situation instead of guessing at a margin.
