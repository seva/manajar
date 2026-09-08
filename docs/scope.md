# Scope - Maximal Imaginable

Established 2026-09-08 (scaffold port #6; draft for Owner review). Strategy artifact: the ladder this project climbs. Orient (CYCLE.md, step 1) measures the status quo against this document.

**Maximal mission:** Player-owned LLMs become a standard mechanics layer of user-generated games — ManaJar is the working demonstration that a game can delegate its core creativity (spell effects) to each player's own AI credentials, safely, at kid scale.

---

## Scope ladder

| Level | Scope | Current system's contribution |
|---|---|---|
| L1 | Core loop verified headless (jar → mana → target → LLM spell → scaling → feedback) | as-is: 11-test suite green, all 7 components implemented |
| L2 | Published Roblox place with end-to-end BYO-LLM casting (Phase 4 gate) | LLMProvider/CredentialStore live against real Gemini/Grok OAuth; DataStore persistence |
| L3 | Public playable game: onboarding, visual spell feedback, content moderation of AI output | Warding hardened against adversarial LLM output; tutorial |
| L4 | Reusable open-source framework: BYO-LLM mechanics for other Roblox games | Provider-agnostic LLMProvider interface, OAuth web app as reference implementation |
| L5 | Universal for the domain: player-owned AI credentials as a commonplace mechanic substrate across UGC platforms | The pattern, not the code: BYO credentials + sanitized generation + deterministic scaling |

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
| Never publish AI-generated content path without Warding active | Child safety; Owner/Roblox account standing |
| Never trade Roblox ToS compliance for release speed | Publisher account (irrecoverable if banned) |
| OAuth consent screen / domain registration: no misleading branding, no scope over-request | Google developer account standing |

| Commitment class | Refinement level (PRAROC-n) | Terms below the cut, registered non-drifting |
|---|---|---|
| Dev steps (code, tests, docs) | PRAROC-2 (Now → Later) — fully recoverable | Roblox Studio/Rojo toolchain availability; Rodeo compatibility |
| Publish-facing (place publication, OAuth consent screen, domain, Vercel project) | PRAROC-3 (Now → Far → Unreachable) — spends reputation/account standing | Vercel free-tier availability; manajar.app domain renewal |
| Platform dependency (Roblox itself) | assumed non-drifting within the commitment interval | Roblox platform continuity; Luau language stability |

## Terminal form

ManaJar-the-bespoke-game becomes unnecessary: BYO-LLM mechanics exist as an off-the-shelf capability (L4 framework adopted by other devs, L5 pattern normalized). The jars and mana are the demonstration vehicle; the pattern is the product.

## Constraint analysis

- L1→L2: binding constraint is place publication (Owner sanction — Roblox account) + Google/xAI OAuth client configuration; composes with current code (no rewrite)
- L2→L3: binding constraint is moderation/safety review of AI output at public scale; Warding exists, needs adversarial hardening — composes
- L3→L4: binding constraint is generalizing LLMProvider beyond ManaJar's spell contract; interface already provider-based — partial rewrite of prompt layer only
- L4→L5: not a code constraint — adoption/ecosystem; outside project jurisdiction
- Nearest concrete anchors: Roblox Creator Hub (publish + DataStore enablement), Google Cloud Console (OAuth consent screen for manajar.app / Vercel callback), xAI developer portal (device-code OAuth client), Vercel project web-app-zeta-six-27
