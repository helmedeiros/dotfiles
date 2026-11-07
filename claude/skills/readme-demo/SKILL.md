---
name: readme-demo
description: Record, update or extend the short demo GIFs embedded in a project's README (VHS for terminal apps, Playwright for web UIs/games/extensions). Use when the user asks to "add a demo video/GIF to the README", "record the app", "re-record the demos", "update the README videos after UI changes", or "make a video of <feature> in <repo>". Three modes - create (first demos for a repo), update (re-record existing demos), feature (add one GIF for a specific new feature).
---

# README demo GIFs

Short (5–15 s) GIFs of the app running for real, kept in `docs/demo/`, embedded right under the README intro, re-recordable with one build-tool target.

## Pick the mode

| User says | Mode |
|---|---|
| "add demo videos to <repo>" / repo has no `docs/demo/` | **create** |
| "re-record / update the demos", UI changed | **update** |
| "make a video of <feature> in <repo>" | **feature** |
| several repos ("all my projects since 2021") | triage first (below), then one subagent per repo, in parallel, each with a distinct port range — except repos whose CLAUDE.md forbids parallel agents: run those alone |

## Ground rules (all modes)

- Follow the repo's own `CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md` (commit style, gates, branch/PR flow).
- Conventional Commits. **No AI attribution anywhere** (no Co-Authored-By, no "Generated with"). No code comments in the recorder/tapes.
- Quality gates green before committing (lint, format, type-check, tests, build).
- Don't touch uncommitted work or the current branch. Dirty tree or in-progress feature branch → `git worktree add <scratchpad>/<repo>-demo -b docs/readme-demo origin/main`. Base on `origin/main` (fetch first) — local `main` is often behind and upstream may have rewritten the README.
- **Scheduled / backdated history** (commits on exact hours, repeated minute:second patterns, last commit months ago, `.git/hr/`, `ROADMAP.local.md`, `PLAN.md` schedules, meta repos): stage everything, don't commit; ask the user how to date it.
- **Show the GIFs to the user before pushing.** Commit locally; push/PR only after they've looked. Then: rebase on `origin/main`, re-run gates, push. Protected `main` → PR (`gh api repos/<o>/<r>/branches/main/protection`); check allowed merge methods before merging (`gh api repos/<o>/<r> --jq '{merge:.allow_merge_commit,rebase:.allow_rebase_merge,squash:.allow_squash_merge}'`).
- Throwaway state only: temp DB/HOME/data dir, committed demo seed, fictional fixtures. Never the user's real data, tokens, playlists, HR records.
- Nothing personal or machine-specific on screen: no shell prompt, no `/Users/...` paths, no LAN IPs, no real names/emails beyond what's already public on the project. Flag employer names that show up.
- README: GIFs right under the intro, relative paths, short alt text, at most one caption line each. **No other README changes.** Don't mention plans/cadence/status.
- Kill every process you started; use only your assigned ports.

## Triage: does it have a screen?

Record: web apps, games, browser extensions (load unpacked against a local fixture page), TUIs, CLIs whose offline output tells a story.
Skip and say why: libraries/backend services with no UI, CLIs that need the user's credentials to show anything, placeholder UIs ("loading..."), uncommitted frontends, damaged repos, private data.

## create

1. **Pick 2–4 views** from README + code: main screen, core interaction, one striking feature. Each GIF = one small story, 5–15 s. Include one human moment if the app has one (typo fixed, error message, wrong move then retry). Tell the user the views in one line each, then go ahead.
2. **Terminal app → VHS** (`brew install vhs` if missing). One `docs/demo/<name>.tape` per view, from `references/template.tape`:
   - Build the binary first and run it (not `go run`/`npm start`).
   - Everything setup goes inside `Hide … Show`: build, `rm` old state, temp HOME/data env, neutral `PS1`, `clear`, launch, navigate to the start screen. Put helpers in a sourced `docs/demo/env.sh` (see `references/env.sh`).
   - Never *type* a helper on screen — viewers will think it's a real command of the app.
   - `Sleep` 1.5–2 s after every change. Quit the app cleanly at the end.
   - Random content (drills, falling letters) → only type the deterministic part; cut before a random ending.
3. **Web UI → Playwright**, one script `docs/demo/record.mjs` (or `.cjs`) with named scenes, from `references/record.mjs`:
   - Build the production bundle and serve it (`vite preview`, `astro preview`, the Go binary, a tiny static server) on your port. Seed via the app's API/demo flag against a temp DB.
   - Pin `playwright@1.49.1` as a devDependency. Launch the bundled Chromium; if it fails, fall back to `channel: 'chrome'` (headless, fresh profile — the user's browser extensions never load). Allow `DEMO_CHANNEL=chrome`.
   - Show a cursor ring for mouse demos; real keypresses for games (`page.keyboard.press` with pauses).
   - Video via `recordVideo`; if frames come out cropped/grey-banded, switch to a timed screenshot sequence.
   - Stub flaky external calls with `page.route` (e.g. image search → fixed images). Block analytics.
   - Two-player/multi-client apps: two contexts side by side, compose with ffmpeg `hstack`.
   - `node:fetch` rejects some ports as "bad port" — pick another in range.
4. **GIF conversion** (≈900 px wide, 8–12 fps):
   ```bash
   ffmpeg -y -i in.webm -vf "fps=10,scale=900:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5" out.gif
   ```
   Trim blank lead-in (`-ss`). Keep each GIF ≤ ~2 MB: lower fps, width or duration; animated backgrounds (water, gradients) cost the most.
5. **Re-record target**: Makefile `demo: build` running `vhs` on each tape, or `"demo": "npm run build && node docs/demo/record.mjs"` in package.json, or a `demo` mode in `build.sh`. **If `demo` already exists with another meaning, use `demo-record`.** Scripts accept a scene name to record just one.
6. **Verify** (mandatory): `bash scripts/frames.sh docs/demo/<name>.gif <outdir>` (from this skill dir) makes a 2×2 contact sheet; Read it and look. Re-record if anything is cut off, too fast, shows a prompt/path/personal data, or the keypresses didn't land.
7. **Embed + commit**: `docs(readme): show <x>, <y> and <z> in action`.

## update

1. Find the existing target (`make demo`, `npm run demo`, `make demo-record`, `./build.sh demo`) and run it on a fresh `origin/main` worktree.
2. If a scene broke because the UI changed (selector gone, lesson renumbered, new menu), fix the scene/tape minimally, keeping the same story.
3. Verify frames as above; compare sizes with `git diff --stat`.
4. Commit `docs(demo): re-record <names> after <change>`. Show the user, then push.

## feature

Input: a repo and a feature (name, PR, commit, or description).

1. Read the feature's diff/code to learn how it is reached and what it does. Pick **one** story that shows it; add a mistake moment if natural.
2. Reuse the repo's existing setup: add a new tape `docs/demo/<feature>.tape` or a new scene in `record.mjs`. If there's no demo setup yet, do **create** with this feature as one of the views.
3. Make sure the `demo` target includes it; record just that scene.
4. Verify frames.
5. Embed the GIF under the existing demo GIFs (one caption line). Keep the total at ≤ 4 GIFs; if over, ask which one to replace.
6. Commit `docs(readme): show <feature> in action`. Show the user, then push or open a PR per the repo's flow.

## Final report to the user

Per repo: views picked (one line each), commit/branch/PR, GIF paths (absolute) to review, and anything to check (oversized GIF, employer name visible, helper on screen, gates already failing on main, skipped and why).
