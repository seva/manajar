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

## Phase 2: Vertical Slice

- [ ] Verification: Set up Roblox Studio project, wire Phase 1 components into playable scene, playtest core loop
- [ ] (Further tasks TBD)

_Last updated: 2026-07-18_  

## Project Structure (reference)

```
src/
├── Shared/
│   ├── ManaJar/init.luau        # Jar CRUD + mana management
│   ├── ManaJar/Types.luau       # Jar type definitions
│   ├── ManaInput/init.luau      # Input accumulation + jar filling
│   ├── Targeting/init.luau      # Target registry + selection
│   ├── SpellCaster/init.luau    # Prompt building + LLM provider abstraction
│   ├── SpellCaster/Types.luau   # Spell effect type definitions
│   ├── SpellCaster/Warding.luau # LLM output sanitization
│   ├── ManaScaling/init.luau    # Scaling formula + classification
│   ├── EffectApplier/init.luau  # Effect application + summaries
│   └── Feedback/init.luau       # Display data for UI
├── Server/                      # Server-side scripts (TBD)
└── Client/                      # Client-side scripts (TBD)
tests/
└── Shared/                      # Mirrors src/Shared structure
    ├── ManaJar/
    ├── ManaInput/
    ├── Targeting/
    ├── SpellCaster/
    ├── ManaScaling/
    ├── EffectApplier/
    └── Feedback/