# ManaJar

A Roblox game where players put mana into jars, link them to targets, and cast LLM-generated spells whose effects scale based on invested mana vs target resistance.

## Current Phase

**Phase 4** — Integration & Validation ([#5](https://github.com/seva/manajar/issues/5))

## Session Start

1. Read `METHODOLOGY.md`
2. Read `ARCHITECTURE.md` — verify component descriptions match current code before acting
3. Scan `IMPLEMENTATION.md` checkboxes — first unchecked task is current state
4. Check open GitHub issues for failures and decisions
5. Search memory for relevant prior knowledge
6. Locate the project in the operating cycle (`CYCLE.md`) — which step is current?
7. Identify your role (`ROLES.md`; default Steward) and the declared role instances — no role grades its own work

## Conventions

- Language: Luau (Roblox)
- Runtime: Roblox Studio
- Test runner (Luau): Rodeo v1.3.0 at `C:\Users\seval\bin\rodeo\rodeo.exe` — `rojo build` → `rodeo run --place <rbxlx> --mode edit --context plugin --show-return test-runner.luau`. Baseline: 12 passed, 0 failed, 1 skipped (SetupRemotes_spec — monkey-patches Instance.new, read-only in Studio; documented in `test-runner.luau`)
- Test runner (web app): Jest — `npm test` in `web-app/`
- Formatting / linting: Standard Roblox Luau style
- AI Coding Agent (Steward): OpenCode
- LLM for spell generation: Google Gemini (OAuth) + xAI Grok (OAuth) — BYO, player-owned credentials only; never game-side API keys
- Project focus: Simple, kid-friendly core loop first. No over-engineering.
- Scope position per `docs/scope.md`: **L1** (core loop verified headless); next rung L2 (published place, end-to-end BYO-LLM casting)
- Refinement level: PRAROC-2 (Now → Later) for dev steps — all commitments recoverable; PRAROC-3 (Now → Far → Unreachable) for publish-facing commitments (place publication, OAuth consent screen, domain) which spend reputation/account standing
- Role instances (`ROLES.md`): **Owner** = Seva Lapsha (@seva); **Steward** = OpenCode session; **Critic** = distinct-model session (Grok or Gemini via OpenCode, fresh context — never the Steward session); **Auditor** = MetaThrone (Claude Code session)

## Declared Deviations

- **Headed Tests** (ManaJar addition, not in upstream scaffold) — headless tests verify logic; headed tests verify integration in Roblox Studio. Protocol:
  1. Build the place file via `rojo build`
  2. Launch Studio with the built place: `Start-Process -FilePath RobloxStudioBeta.exe -ArgumentList "$placeFile"`
  3. Wait for Studio to load (15s)
  4. Send F5 via pyautogui: `win.activate()` → `pyautogui.press('f5')`
  5. Wait for play mode to initialize (10s)
  6. Capture Output window content (click Output tab → Ctrl+A → Ctrl+C)
  7. Take screenshot of the game viewport
  8. Assert: `PlaySoloSuccess` appears in `%LOCALAPPDATA%\Roblox\logs\*Studio*.log`
  9. Assert: diagnostic `warn()` output from bootstrap scripts appears in Output
  10. Assert: HUD elements (ScreenGui, TextLabel) are visible (screenshot or Instance check)
  11. Assert: no script errors in Output
  - Verification evidence: screenshot + Output text, committed to the issue comment
  - Cadence: at phase boundaries, not per-commit; phase verification requires at least one headed run
  - Known failure mode: "Studio process exited during launch" = pending forced Studio update; launch `RobloxStudioBeta.exe` manually, let `RobloxStudioInstaller` finish, retry
- **ARCHITECTURE.md Engineering Invariants — partial applicability**: no ORM (Banned Pattern row 1 N/A); schema evolution = DataStore key versioning (Expand→Contract applies to credential schema); idempotency guards apply to RemoteEvent handlers (server-side dedupe of client retries)
- **Test authenticity deviation**: Roblox service dependencies (DataStore, HttpService) cannot run in ephemeral containers; Studio-context tests skip DataStore paths (documented in test-runner.luau) and are covered by integration tests on the published place (Phase 4 §3). Mocks remain restricted to external LLM APIs.
