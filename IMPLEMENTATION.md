# Implementation

---

## Phase 0: Discovery (Complete)

Artifacts:
- `docs/discovery-llm-provider.md` — LLM provider evaluation, structured output schema
- `docs/discovery-roblox-luau.md` — Module system, Roblox services, types, Rojo
- `docs/discovery-test-framework.md` — Test framework evaluation, structure

---

## Phase 1: Core Loop Prototype

- [x] Write Mana Jar system tests
- [x] Implement basic Mana Jar system (Create, fill, link, drain)
- [x] Write mana input tests
- [x] Implement mana input
- [x] Write target linking tests
- [x] Implement target linking
- [x] Write SpellCaster tests
- [x] Implement LLM spell casting with structured output
- [x] Write Warding tests
- [x] Implement spell output sanitization
- [x] Write mana scaling tests
- [x] Implement mana scaling vs target strength
- [x] Write feedback tests
- [x] Basic visual feedback for scaling
- [x] Write EffectApplier tests
- [x] Implement EffectApplier

---

## Phase 2: Vertical Slice ([#2](https://github.com/seva/manajar/issues/2))

- [x] Write GameManager tests
- [x] Rojo config and Studio project setup
- [x] Write SetupRemotes tests
- [x] Write server game loop tests
- [x] Server game loop wiring (GameManager, remotes)
- [x] Fix targeting state caching bug (found by tests)
- [x] Rename tests/Shared/ → tests/ReplicatedStorage/
- [x] Fix ARCHITECTURE.md structure listing
- [x] Write client input handler tests
- [x] Client input handler
- [x] Playtest: core loop is understandable in 5 minutes
- [ ] (Further tasks TBD)

---

## Phase 3: LLM Integration ([#4](https://github.com/seva/manajar/issues/4))

### Discovery & Design (Complete)
- [x] **Product research: BYO LLM provider requirement** — document discovery artifact `docs/discovery-byo-provider.md`
- [x] Research Google Gemini OAuth flow (endpoints, scopes, token refresh)
- [x] Research xAI Grok OAuth flow (endpoints, scopes, token refresh)
- [x] Design credential storage schema (DataStore)
- [x] Design auth flow (external web app or in-game URL)
- [x] Document implementation design in `docs/discovery-byo-provider.md`

### Implementation (Complete)
- [x] Create OAuth callback web app (Vercel + manajar.app)
- [x] Implement Google Gemini OAuth flow
- [x] Implement xAI Grok OAuth flow (device code)
- [x] Create CredentialStore module (DataStore integration)
- [x] Create LLMProvider module (Gemini + Grok support)
- [x] Implement spell generation with real LLM calls
- [x] Add error handling and retry logic
- [x] Implement per-user rate limiting (5s cooldown)
- [x] Add token counting and cost display
- [x] Replace MockLLMProvider with real LLMProvider
- [x] Wire into GameManager.OnPlayerCastSpell()
- [x] Handle latency (async calls, loading states)
- [x] Handle errors gracefully (show error, no fallback)
- [x] Unit tests for LLMProvider module
- [x] Integration tests for end-to-end spell generation
- [x] Test error cases (API down, timeout, invalid response)
- [x] Test output validation (Warding)

### Open Questions (Resolved)
- [x] Web app hosting for OAuth callback (Vercel, Netlify, self-hosted?) → **Vercel**
- [x] Domain for OAuth flow → **manajar.app**
- [x] Fallback strategy if no provider connected → **Error message, block spell casting**
- [x] Rate limiting strategy → **Per-user cooldown (1 spell per 5 seconds)**
- [x] Cost tracking for Gemini (pay-per-token) → **Basic token counting, display to user**

_Last updated: 2026-07-19_