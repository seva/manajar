# Methodology

---

## Artifacts

| Artifact | Purpose |
|----------|---------|
| `CLAUDE.md` | Session bootstrap |
| `IMPLEMENTATION.md` | Task state — checkboxes updated in place |
| GitHub issue per phase | Failure record — comments capture attempts and decisions |
| `docs/` outputs | Phase 0 discovery artifacts — hard gates for dependent phases |

---

## Session Protocol

**Start:** Read `CLAUDE.md` → open linked GitHub issue → scan `IMPLEMENTATION.md` checkboxes.

**End:** Update checkboxes + post one comment to the open issue (what was tried, what was found, what's next).

---

## Commit Discipline

Commit at task completion, not session end. One logical unit of work per commit.

**Message format:**
```
<type>(<scope>): <summary>

Closes #N   ← for fix/feat commits that resolve a tracked issue
Refs #N     ← for commits that advance but don't close an issue
```

Rules:
- Every fix commit references its issue (`Closes #N` or `Refs #N`)
- Every phase completion is a commit
- Do not batch unrelated changes into one commit
- `IMPLEMENTATION.md` checkbox updates go in the same commit as the work they track
- Any commit that changes a component's public contract (function signatures, error types, endpoints, CLI interface) must update the corresponding section of `ARCHITECTURE.md` in the same commit

---

## Failure Handling

Any failure triggers the research sequence: **Hypothesis → online (docs + community) → source code.**

Do not retry without diagnosis. Do not proceed to the next task until the failure is understood.
Document findings as a comment on the open phase issue.

---

## Phase Gate

Discovery outputs (Phase 0) are hard prerequisites for implementation phases. No implementation code is written against undiscovered interfaces, APIs, or contracts.

---

## What Goes Where

- **Checkboxes** — task complete or not. Binary.
- **Issue comments** — everything else: failed attempts, decisions, partial findings, blockers.
- **`docs/`** — structured discovery outputs. Committed, permanent, readable by any session.
- **`CLAUDE.md`** — current phase pointer only. Updated when phase changes.
- **`docs/walrus-YYYY-MM-DD.md`** — WaLRuS-DATA session summary. Written at session end, committed.

---

## TDD

Tests are written before implementation code. Done means tests pass, not code written.

- Test files mirror source structure
- Each implementation task is preceded by a test task in `IMPLEMENTATION.md`
- Phase 0 (discovery) is exempt — no implementation code
- "Done" = the verification statement at the bottom of the phase is true

---

## Quality Signals

When a measure becomes a target, it ceases to be a good measure. Optimizing for a metric produces the metric, not the thing the metric was meant to proxy.

**Coverage as diagnostic, not target.** Coverage is never optimized for directly. After significant work, uncovered lines are reviewed and classified:
- *Acceptable* — untestable path (browser automation, stdio transport, subprocess-only code). Document why.
- *Gap* — missing behavior coverage. File an issue or add a test.

The metric stays meaningful because it is never the goal.

**Prefer signals that are hard to fake** — passing integration tests on real infrastructure, user-reported defects, deployment frequency — over signals that are easy to inflate.

---

## Headed Tests

Headless tests (TDD) verify logic. Headed tests verify integration — that code actually runs in the target runtime (Roblox Studio) and produces observable effects.

**Protocol:**
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

**Verification evidence:** Screenshot + Output text. Both are committed to the issue comment.

**Exception:** Heated tests are run at phase boundaries, not per-commit. Phase verification requires at least one headed test run.

---

## What's Excluded and Why

- **Session log** — redundant with issue comments; grows noisy.
- **Branch-per-phase** — doesn't capture intra-phase progress or failures.