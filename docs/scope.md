# Scope - Maximal Imaginable

Established 2026-09-08 (scaffold port #6; draft for Owner review). Strategy artifact: the ladder this project climbs. Orient (CYCLE.md, step 1) measures the status quo against this document.

**Maximal mission:** Player-owned LLMs become a standard mechanics layer of user-generated games — ManaJar is the working demonstration that a game can delegate its core creativity (spell effects) to each player's own AI credentials, safely, at kid scale.

---

## Scope ladder

| Level | Scope | Current system's contribution |
|---|---|---|
| L1 | Core loop verified headless (jar → mana → target → LLM spell → scaling → feedback) | as-is: 12-test suite green (Rodeo/Studio); cast-path scaling wired and covered (#7) |
| L2 | Published Roblox place with end-to-end BYO-LLM casting (Phase 4 gate) | code written, **unexecuted**: CredentialStore ships OAuth client placeholders; nothing has run against real OAuth or a real DataStore |
| L3 | Public playable game: onboarding, visual spell feedback, content moderation of AI output | Warding hardened against adversarial LLM output; tutorial |
| L4 | Reusable open-source framework: BYO-LLM mechanics for other Roblox games | provider dispatch is internal to LLMProvider (hardcoded gemini/grok branches); provider-agnostic abstraction planned, not built. OAuth web app as reference implementation |
| L5 | Universal for the domain: player-owned AI credentials as a commonplace mechanic substrate across UGC platforms | the pattern, not the code: BYO credentials + sanitized generation + deterministic scaling. Measured by ecosystem adoption — outside project jurisdiction; Owner-level rung |

---

## Functional depth

- Warding (safety of generated content) deepens at every level — kid-friendly bar rises with audience size
- Provider abstraction (Gemini, Grok, future) widens without touching game logic
- Mana economy (scaling formula, resistance) tunes toward legible player feedback

## Survivability

- Adversarial LLM output (prompt injection via spell text, oversized/malformed effects) → Warding type+range validation; JSON-only contract
- Credential abuse → BYO OAuth, server-side DataStore only, no game-side API keys (invariant; learned via 2026-07-26 drift incident #5)
- Platform risk → Roblox ToS/moderation compliance for AI-generated content; kid-safety (COPPA-adjacent) constraints
- Economic → zero game-side LLM cost by construction (players' own subscriptions)

## Terminal bound

| Compiled constraint | Irrecoverable margin it protects |
|---|---|
| Never store or ship game-side LLM API keys | Owner's accounts/billing standing with Google/xAI; project's BYO promise |
| Never ship OAuth client secrets inside the distributed place file (known design gap: CredentialStore.RefreshCredentials currently embeds client_id/client_secret — must move server-side/web-app before publish) | Same margin class: Owner's Google/xAI account standing |
| Never collect or store children's credentials or personal data beyond the strict minimum for BYO OAuth; COPPA/FTC review before publication | Legal standing, Owner reputation, Roblox publisher account |
| Never publish AI-generated content path without Warding active | Child safety; Owner/Roblox account standing |
| Never trade Roblox ToS compliance for release speed | Publisher account (irrecoverable if banned) |
| OAuth consent screen / domain registration: no misleading branding, no scope over-request | Google developer account standing |

| Commitment class | Refinement level (PRAROC-n) | Terms below the cut, registered non-drifting |
|---|---|---|
| Dev steps (code, tests, docs) | PRAROC-2 (Now → Later) — fully recoverable | Roblox Studio/Rojo toolchain availability; Rodeo compatibility |
| Publish-facing (place publication, OAuth consent screen, domain, Vercel project) | PRAROC-3 (Now → Far → Unreachable) — spends reputation/account standing | Vercel free-tier availability; manajar.app domain renewal |
| Platform dependency (Roblox itself) | assumed non-drifting within the commitment interval | Roblox platform continuity; Luau language stability |

Tracked drifting terms (fastest drift × consequence, per HORIZONS.md — these are NOT below the cut):
- **Roblox AI-generated-content policy** — drifts toward restriction; consequence at L2+: place removal. Named as survivability risk above; checked every Orient against the publish-facing commitment.
- **Google OAuth app-verification requirements** — drifts; gates L1→L2 (unverified consent screen → limited/test-user-only OAuth). Checked every Orient.

## Terminal form

ManaJar-the-bespoke-game becomes unnecessary: BYO-LLM mechanics exist as an off-the-shelf capability (L4 framework adopted by other devs, L5 pattern normalized). The jars and mana are the demonstration vehicle; the pattern is the product.

## Constraint analysis

- L1→L2: binding constraint is place publication (Owner sanction — Roblox account) + Google/xAI OAuth client configuration; composes with current code (no rewrite)
- L2→L3: binding constraint is moderation/safety review of AI output at public scale; Warding exists, needs adversarial hardening — composes
- L3→L4: binding constraint is generalizing LLMProvider beyond ManaJar's spell contract; interface already provider-based — partial rewrite of prompt layer only
- L4→L5: not a code constraint — adoption/ecosystem; outside project jurisdiction
- Nearest concrete anchors: Roblox Creator Hub (publish + DataStore enablement), Google Cloud Console (OAuth consent screen for manajar.app / Vercel callback), xAI developer portal (device-code OAuth client), Vercel project web-app-zeta-six-27
