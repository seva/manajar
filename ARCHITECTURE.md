# Architecture

---

## Principles

**Separation of concerns** — jar management, mana handling, targeting, spell generation, and effect application are separate modules.

**Isolation of fragility** — LLM calls and external dependencies are contained.

**Security** — Generated spells are sanitized (Warding).

---

## Coding Hygiene

Guard clauses. Graceful degradation. Explicit error types.

Code as documentation.

---

## System Diagram

```
[Player] --> Jar (mana input) --> Link Target --> LLM Spell Generation --> Scaled Effect on Target
```

_Last verified: 2026-07-18_

---

## Components

| Component | Responsibility | Key interface |
|-----------|----------------|---------------|
| JarSystem | Manage mana jars | Create, fill, link target |
| Targeting | Link targets to jars | SelectTarget() |
| SpellCaster | LLM call and scaling | CastSpell(prompt, mana, target) |
| EffectApplier | Apply scaled effect | ApplyEffect(target, effect, scale) |

_Last verified: 2026-07-18_

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| | | |

_Last verified: 2026-07-18_

---

## Constraints

- Roblox Luau
- Kid-friendly simplicity
- LLM output must be structured and safe

_Last verified: 2026-07-18_