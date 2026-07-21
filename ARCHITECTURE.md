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

## Project Structure

```
src/
├── ReplicatedStorage/     # Shared modules (accessible by server + client)
│   ├── ManaJar/
│   ├── ManaInput/
│   ├── Targeting/
│   ├── SpellCaster/ (includes Warding.luau)
│   ├── ManaScaling/
│   ├── EffectApplier/
│   └── Feedback/
├── ServerScriptService/   # Server-side scripts
│   ├── Bootstrap.server.luau # Entry point: requires modules, wires RemoteEvents (Script)
│   ├── GameManager.luau      # Main game loop wiring (ModuleScript)
│   ├── SetupRemotes.luau     # RemoteEvent creation (ModuleScript)
│   └── LLMProvider/          # LLM integration with OAuth
│       ├── init.luau         # LLMProvider module (Gemini + Grok)
│       └── CredentialStore.luau # DataStore-based credential management
└── StarterPlayer/
    └── StarterPlayerScripts/  # Client scripts
        ├── Bootstrap.client.luau # Entry point: input handling, ScreenGui (LocalScript)
        └── ClientHandler.luau    # Input handling + remote event dispatch (ModuleScript)
web-app/                     # OAuth callback web app (Vercel)
├── pages/
│   ├── api/auth/
│   │   ├── gemini.ts       # Gemini OAuth callback
│   │   ├── grok-device.ts  # Grok device code flow
│   │   └── grok-poll.ts    # Grok token polling
│   └── auth.tsx            # OAuth entry point
└── tests/                  # Jest tests for web app
tests/
├── ReplicatedStorage/                    # Mirrors src/ReplicatedStorage
├── ServerScriptService/                  # Mirrors src/ServerScriptService
└── StarterPlayer/StarterPlayerScripts/   # Mirrors src/StarterPlayer/StarterPlayerScripts
```

## System Diagram

```
[Player] --> ManaInput --> JarSystem (fill jar) --> Targeting (link target)
                               |
                               v
[OAuth] --> CredentialStore <-- LLMProvider --> SpellCaster (build prompt) <-- JarSystem (drain mana) + Targeting (get target)
   |                                              |
   v                                              v
[Web App]                                    [LLM API]
(Gemini/Grok OAuth)                          (Gemini/Grok)
   |                                              |
   v                                              v
[DataStore]                                 Warding (sanitize) --> ManaScaling (mana vs resistance) --> EffectApplier (apply to target)
                                                  |
                                                  v
                                            Feedback (display result to player)
```

_Flow: Player authenticates via web app → credentials stored in DataStore → LLMProvider retrieves credentials → calls LLM API → generates spell effect_

_Last verified: 2026-07-20_

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
| ClientHandler | Client-side input handling and remote dispatch | Create, StartFill, StopFill, CastSpell, SelectTarget, OnUpdateJar |
| LLMProvider | Manage LLM API calls with OAuth credentials | GenerateSpell(userId, request), GetProviderInfo, DisconnectProvider |
| CredentialStore | Store and retrieve OAuth credentials in DataStore | SaveCredentials, GetCredentials, DeleteCredentials, RefreshCredentials, IsTokenExpired |

_Last verified: 2026-07-20_

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
| LLM provider auth | BYO OAuth (Gemini + Grok) | Players use their own subscriptions; no game-side API costs |
| Credential storage | Roblox DataStore | Server-side only, encrypted at rest, per-user isolation |
| Web app hosting | Vercel (manajar.app) | Free tier, serverless functions, easy OAuth callback |

_Last verified: 2026-07-20_

---

## Constraints

- Roblox Luau
- Kid-friendly simplicity
- LLM output must be structured and safe
- Players must provide their own LLM credentials (BYO OAuth)
- OAuth credentials stored server-side only (DataStore)

_Last verified: 2026-07-20_