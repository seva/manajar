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

### Implementation (Pending Decisions)
- [ ] Choose LLM provider (OpenAI, Anthropic, or local)
- [ ] Set up API credentials (environment variables or config)
- [ ] Handle API keys securely (not in code)
- [ ] Create src/ReplicatedStorage/LLMProvider/init.luau
- [ ] Implement GenerateSpell(request) -> spell_effect
- [ ] Handle API calls with proper error handling
- [ ] Add timeout and retry logic
- [ ] Rate limiting and cost tracking
- [ ] Design system prompt for spell generation
- [ ] Define structured output schema (JSON)
- [ ] Test prompt variations for quality
- [ ] Ensure output is safe and kid-friendly
- [ ] Replace MockLLMProvider() with real LLMProvider
- [ ] Wire into GameManager.OnPlayerCastSpell()
- [ ] Handle latency (async calls, loading states)
- [ ] Handle errors gracefully (fallback to mock?)
- [ ] Unit tests for LLMProvider module
- [ ] Integration tests for end-to-end spell generation
- [ ] Test error cases (API down, timeout, invalid response)
- [ ] Test output validation (Warding)

### Open Questions (Blockers)
- [ ] Web app hosting for OAuth callback (Vercel, Netlify, self-hosted?)
- [ ] Domain for OAuth flow
- [ ] Fallback strategy if no provider connected
- [ ] Rate limiting strategy
- [ ] Cost tracking for Gemini (pay-per-token)

_Last updated: 2026-07-19_