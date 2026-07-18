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
[Player] --> ManaInput --> JarSystem (fill jar) --> Targeting (link target)
                              |
                              v
[LLM] <-- SpellCaster (build prompt) <-- JarSystem (drain mana) + Targeting (get target)
  |
  v
Warding (sanitize) --> ManaScaling (mana vs resistance) --> EffectApplier (apply to target)
  |
  v
Feedback (display result to player)
```

_Last verified: 2026-07-18_

---

## Components

| Component | Responsibility | Key interface |
|-----------|----------------|---------------|
| JarSystem | Manage mana jars | CreateJar, FillJar, LinkTarget (returns (bool, string?)), DrainJar |
| ManaInput | Accumulate player input into mana | ProcessInput, FillJarFromInput |
| Targeting | Register/select/link targets to jars | RegisterTarget, SelectTarget, LinkJarToSelected (all return (bool, string?)) |
| SpellCaster | Build prompt and call LLM | BuildPrompt, CastSpell |
| Warding | Sanitize raw LLM output | SanitizeSpellEffect, SanitizeLLMResponse(jsonDecode) |
| ManaScaling | Compute scale factor from mana vs resistance | CalculateScaleFactor, ComputeSpellEffect |
| EffectApplier | Apply scaled effect to target | ApplyEffect(targetId, effect) |
| Feedback | Build display data for UI | BuildSpellResultDisplay, BuildJarDisplay |

_Last verified: 2026-07-18_

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scaling formula | mana / (mana + resistance) * 2 | Normalized to 1.0 when mana = resistance; intuitive range 0-2 |
| Scale tiers | 5 tiers (weak to very_strong) | Kid-friendly feedback with clear visual distinction |
| Effect types | limited to 5 (damage/heal/stun/buff/debuff) | Simple, covers core gameplay patterns |
| Warding approach | type + range validation after JSON decode | Defense-in-depth: early rejection of malformed LLM output |
| Input accumulation | time-based with fillRate multiplier | Simple hold-to-fill pattern; works with delta-time from Roblox RunService |
| Provider model | interface-based LLMProvider | Swappable for different LLM backends; testable via mocks |

_Last verified: 2026-07-18_

---

## Constraints

- Roblox Luau
- Kid-friendly simplicity
- LLM output must be structured and safe

_Last verified: 2026-07-18_