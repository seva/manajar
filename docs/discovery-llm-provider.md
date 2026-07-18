# Discovery: LLM Provider

_Phase 0 artifact. Post-hoc reconstruction._

## Requirement

Player spell intent + mana + target info → structured spell effect JSON. Must be callable from Roblox (HttpService, server-side only).

## Options Evaluated

| Provider | Roblox HttpService | Structured Output | Cost | Verdict |
|----------|-------------------|-------------------|------|---------|
| OpenAI | ✅ HTTPS POST | ✅ JSON mode / function calling | Pay-per-token | Viable |
| Anthropic | ✅ HTTPS POST | ✅ JSON mode | Pay-per-token | Viable |
| OpenRouter | ✅ HTTPS POST (unified API) | ✅ Passes through provider | Pay-per-token + margin | Viable, agnostic |
| Built-in Roblox AI | ❌ No public API | ❌ | N/A | Not viable |

## Decision

**Provider: TBD** (deferred to Phase 2). The `LLMProvider` interface in SpellCaster supports any backend. Actual API key management and provider selection need Seva's input.

## Constraints

- Calls must go through `HttpService:PostAsync` (server-side only)
- Response time: <5s timeout, handle failure gracefully
- Structured output via JSON schema in the system prompt (or provider-native JSON mode when selected)
- No hardcoded API keys in code (environment or DataStore)

## Structured Output Schema

```json
{
  "spellName": "string (max 100 chars)",
  "description": "string (max 500 chars)",
  "effectType": "damage | heal | stun | buff | debuff",
  "baseValue": "number (0 - 1,000,000)",
  "scaledValue": "number (0 - 1,000,000)",
  "duration": "number | null (0-300, only for stun/buff/debuff)"
}
```

## Open Questions

- Should we use OpenRouter for provider agnosticism or a direct provider?
- Rate limits on Roblox HttpService (standard limit: ~500 req/min per place)
- Cost budget per user session
