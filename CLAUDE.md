# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page static site for FFB (Fitness Festival Brussels), a fitness event landing page. There is no build system, no package manager, and no framework — everything lives in one file: [index.html](index.html). CSS is inline in a `<style>` block, JS is inline in a `<script>` block at the bottom, and the page content is in French.

Assets referenced from `index.html`: [logo.jpg](logo.jpg), [hero.png](hero.png) (hero background image), [hero.mp4](hero.mp4) (currently unused by the markup — the hero uses `hero.png`, not the video).

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

The page is one long scrolling document composed of stacked sections, all anchored by nav links (`#programme`, `#coachs`, `#lieu`, `#partenaires`, `#billetterie`):

- **Hero** — full-bleed background image (`.hero-video` class name is legacy from when a video was used; it now points at `hero.png`) with a scroll-based parallax effect driven by inline JS.
- **Ticker** — an infinite auto-scrolling marquee of event facts; built by duplicating the same set of `.ticker-item`s twice in markup for a seamless CSS `@keyframes` loop.
- **Programme (`#programme`)** — accordion-style timeline (`.t-item` / `.t-row` / `.t-desc`). Each course row has a fixed `id` (e.g. `#cours-body-pump`, `#cours-body-combat`) that is linked to from the coach tags below — clicking a coach's course tag opens and scrolls to that course.
- **Billetterie (`#billetterie`)** — pricing cards linking out to Billetweb (`billetweb.fr`) ticket sales, opened in a popup window via inline `onclick`.
- **Coachs (`#coachs`)** — an infinite-loop carousel built by JS: the original card set is cloned twice (once prepended, once appended) to fake infinite scrolling, then the track is jumped to the middle set on load. Coach `.coach-tag` links point to `#cours-*` anchors and are wired via event delegation on the track (so it works for both original and cloned cards).
- **Lieu (`#lieu`)** — venue info with an embedded Google Maps iframe.
- **Partenaires (`#partenaires`)** — placeholder logo slots (marked with a TODO comment in the markup) awaiting real partner logos.
- **Scroll reveal** — any element with class `.reveal` (optionally `data-delay="1|2|3"` for staggered timing) fades/slides in via a single shared `IntersectionObserver`, respecting `prefers-reduced-motion`.

## Conventions to preserve when editing

- Keep everything self-contained in `index.html` — no build step exists to bundle separate CSS/JS files.
- Course anchor IDs (`#cours-*`) and coach tag `href`s must stay in sync; adding/renaming a course in the programme section requires updating any coach tags that reference it.
- New animated-in elements should get the `.reveal` class (and `data-delay` if staggering within the same section) to match existing scroll-in behavior.
- Color/spacing tokens are CSS custom properties defined in `:root` (`--black`, `--cream`, `--yellow`, `--red`, `--green`, `--radius`, `--shadow*`) — reuse these rather than hardcoding new colors.
