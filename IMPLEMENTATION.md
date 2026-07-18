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

_Last updated: 2026-07-18_