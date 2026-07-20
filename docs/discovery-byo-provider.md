# Discovery: BYO LLM Provider (OAuth)

_Phase 3 prerequisite. Product research to clarify original requirement._

## Requirement Clarification

**Original requirement:** "BYO provider (OAuth)"

**Interpretation:** Players bring their own LLM provider credentials via OAuth authentication, using their subscription plans rather than the game paying per-token.

## Gamer Persona Analysis

**Target audience:** Roblox players — primarily kids and teens

### Demographics (2025-2026)
- **Under 13:** ~35-40% of users
- **13-17:** ~16-22% of users
- **18-24:** ~21-25% of users (fastest-growing)
- **25+:** ~19% of users

**Key insight:** ~60% of players are under 18. Most are players/consumers, not developers.

### Technical Capability
- **Low (majority):** Comfortable with game navigation, avatar customization, social features. Limited technical knowledge.
- **Intermediate:** Teens who experiment with Roblox Studio, follow tutorials.
- **Advanced:** Dedicated creators (rare) who master Lua scripting and game development.

### Implications for Authentication
**Players cannot and will not:**
- Generate API keys from developer consoles
- Understand what "API keys" are
- Manage per-token billing
- Configure technical settings

**Players expect:**
- Seamless authentication (like signing into a game)
- Click button → authenticate via browser → done
- Use existing subscriptions (ChatGPT Plus, Claude Pro, etc.)
- No technical configuration

**Conclusion:** OAuth is required. API keys are not acceptable for the target persona.

## Research Findings

### OAuth Support by Provider (2026)

| Provider | OAuth Support | Use Case | Notes |
|----------|---------------|----------|-------|
| **Google Gemini** | ✅ Full OAuth 2.0 | API access, model tuning | Strong support, Google account OAuth |
| **xAI (Grok)** | ✅ OAuth (PKCE/device flow) | SuperGrok/X Premium+ subscription | No separate API key needed for subscribers |
| **OpenAI** | ⚠️ Limited | ChatGPT/Codex subscription reuse | No standard OAuth for core API; API keys preferred |
| **Anthropic** | ⚠️ Restricted | Claude Pro/Max subscription | OAuth tokens (`sk-ant-oat01-...`) restricted to official products; ToS violations for third-party use |
| **Mistral** | ❌ No OAuth | API keys only | Standard Bearer token |
| **Together AI** | ❌ No OAuth | API keys only | Account login uses OAuth, API uses keys |
| **Fireworks AI** | ❌ No OAuth | API keys only | Standard Bearer token |
| **Groq** | ❌ No OAuth | API keys only | Fast inference, OpenAI-compatible |

### Key Findings

1. **API Keys dominate** — Most providers use `Authorization: Bearer <key>` for production API access
2. **OAuth is for subscriptions** — Tying to paid plans (ChatGPT Plus, Grok Premium, Claude Max) without separate billing
3. **Google Gemini is the exception** — Full OAuth 2.0 support for API access
4. **Anthropic restricts OAuth** — ToS limits OAuth tokens to official Claude products only
5. **BYO pattern** — Users provide their own credentials; game doesn't pay for LLM calls

### BYO Implementation Patterns

**Pattern 1: API Key Storage**
- User provides API key (e.g., `sk-...`)
- Stored per-user in Roblox DataStore
- Server retrieves key before LLM call
- User pays per-token via their account

**Pattern 2: OAuth Token Storage**
- User authenticates via OAuth flow (browser-based)
- Access token + refresh token stored server-side
- Token refresh handled automatically
- User's subscription covers costs

**Pattern 3: Gateway/Proxy**
- User authenticates with provider
- Game uses gateway (OpenRouter, LiteLLM) to route calls
- Gateway handles authentication abstraction
- Single integration point for multiple providers

## Constraints for Roblox

1. **Server-side only** — HttpService calls must originate from server scripts
2. **No client-side credentials** — API keys/tokens cannot be exposed to clients
3. **DataStore for persistence** — User credentials stored in Roblox DataStore
4. **OAuth flow complexity** — Requires external browser for authentication
5. **Token refresh** — OAuth tokens expire; need refresh logic
6. **Cost management** — Users pay their own bills; no game-side cost tracking needed

## Recommended Approach

### Option A: API Key (Simplest)
**Pros:**
- Simple implementation
- Works with all providers
- No OAuth complexity
- No token refresh logic

**Cons:**
- Users must generate API keys (friction)
- Per-token billing (not subscription)
- Key management burden on users

**Implementation:**
```luau
-- User provides API key via UI or command
-- Store in DataStore: { [userId] = { provider = "openai", apiKey = "sk-..." } }
-- Server retrieves key before LLM call
```

### Option B: OAuth (Subscription-based)
**Pros:**
- Users leverage existing subscriptions
- No per-token billing
- Better UX for non-technical users

**Cons:**
- Complex OAuth flow (external browser)
- Token refresh logic required
- Limited provider support (only Gemini, xAI)
- ToS restrictions (Anthropic)

**Implementation:**
```luau
-- OAuth flow: redirect to provider → user authenticates → callback with token
-- Store: { [userId] = { provider = "gemini", accessToken = "...", refreshToken = "...", expiresAt = ... } }
-- Server refreshes token if expired, then makes LLM call
```

### Option C: Hybrid (API Key + OAuth)
**Pros:**
- Flexibility for users
- Support both subscription and pay-per-token
- Fallback options

**Cons:**
- More implementation complexity
- Need to handle multiple auth patterns

**Implementation:**
```luau
-- User chooses: "Use API Key" or "Use OAuth"
-- Store auth method + credentials per-user
-- Server handles both patterns
```

## Recommendation

**OAuth is required** (gamer persona cannot use API keys).

**Constraint:** OAuth support is limited to Google Gemini and xAI Grok. Most providers (OpenAI, Anthropic) do not support OAuth for third-party API access.

**Phase 3 approach:**
1. **Start with Google Gemini OAuth** — full OAuth 2.0 support, players use their Google account
2. **Add xAI Grok OAuth** — players use their X Premium+/SuperGrok subscription
3. **Future:** Investigate if OpenAI/Anthropic add OAuth support, or use gateway/proxy

**Implementation priority:**
- Google Gemini OAuth flow (Phase 3)
- xAI Grok OAuth flow (Phase 3 or 4)
- Other providers (Phase 4+, if OAuth becomes available)

## Open Questions

1. **Which providers to support first?**
   - OpenAI (most popular, API key)
   - Google Gemini (OAuth support)
   - Anthropic (API key, but ToS restrictions on OAuth)

2. **How to handle OAuth flow in Roblox?**
   - External browser → callback URL → token storage
   - Requires web server for OAuth callback
   - Or use device code flow (no callback needed)

3. **Credential storage security?**
   - Roblox DataStore (encrypted at rest)
   - Per-user isolation
   - No client-side access

4. **Fallback behavior?**
   - If user has no credentials → error message
   - If API call fails → retry logic
   - If provider down → fallback provider?

## Next Steps

1. **Decide:** API key only, or API key + OAuth?
2. **Choose providers:** OpenAI, Gemini, or both?
3. **Design credential storage:** DataStore schema
4. **Implement LLMProvider module:** Abstract auth pattern
5. **Add OAuth flow:** If supporting subscriptions

## Decision Required

**OAuth is required** (gamer persona constraint).

**Seva to decide:**
- Which OAuth providers to support first? (Google Gemini, xAI Grok, or both?)
- Should we implement both in Phase 3, or start with one?
- What's the fallback if a player doesn't have a supported subscription?

---

## Alternative Approach: Browser Session Hijacking

**Inspiration:** [grok-research-mcp](https://github.com/seva/grok-research-mcp)

### Pattern

1. **Browser-based auth** — User logs in via headed browser (Playwright)
2. **Token extraction** — Capture session cookies from browser
3. **Headless LLM interaction** — Use cookies in HTTP client to call web API

### grok-research-mcp Implementation

```python
# auth/browser.py
async def capture(timeout: int = 300) -> dict:
    # Launch headed browser
    browser = await playwright.chromium.launch(headless=False)
    context = await browser.new_context()
    page = await context.new_page()
    
    # Navigate to login page
    await page.goto("https://grok.com/sign-in")
    
    # Wait for user to authenticate (poll for cookies)
    while True:
        cookies = await context.cookies()
        if _has_required_cookies(cookies):  # sso, sso-rw
            break
        await asyncio.sleep(2)
    
    # Capture cookies + statsig_id
    cookies = await context.cookies()
    statsig_id = await page.evaluate("localStorage.getItem('statsig_id')")
    await browser.close()
    
    return {"cookies": cookies, "statsig_id": statsig_id}

# client/session.py
# Use cookies in httpx session for API calls
session = httpx.AsyncClient(cookies=cookie_dict)
response = await session.post("https://grok.com/conversations/new", ...)
```

### Applicability to Other Providers

| Provider | Web Interface | Session Cookies | Bot Detection | Feasibility |
|----------|---------------|-----------------|---------------|-------------|
| **Grok** | grok.com | ✅ sso, sso-rw | ✅ (handled) | ✅ Proven |
| **ChatGPT** | chat.openai.com | ✅ session cookies | ✅ (likely strict) | ⚠️ Possible |
| **Claude** | claude.ai | ✅ session cookies | ✅ (likely strict) | ⚠️ Possible |
| **Gemini** | gemini.google.com | ✅ session cookies | ✅ (likely strict) | ⚠️ Possible |

**Technical feasibility:** Any web-based LLM service can be accessed this way, but:
- Requires reverse-engineering web API endpoints
- May violate ToS (unofficial API access)
- Requires handling bot detection (fingerprinting, CAPTCHAs)
- Session cookies expire (typically 30 days)
- Requires browser automation library (Playwright, Selenium)

### Roblox Constraints

**Problem:** Roblox cannot run Playwright/Selenium on servers.

**Solutions:**

#### Option A: External Auth Service
```
User → Browser (Playwright) → Auth Service (captures cookies) → Roblox DataStore
Roblox Server → DataStore → HTTP calls with cookies → LLM web API
```

**Pros:**
- Works for any provider
- No official API needed

**Cons:**
- Requires external service (cost, complexity)
- ToS violations likely
- Bot detection challenges
- Session expiry management

#### Option B: Pre-Authenticated Sessions
```
User runs local auth tool (Playwright) → Captures cookies → Stores in Roblox DataStore
Roblox Server → DataStore → HTTP calls with cookies → LLM web API
```

**Pros:**
- No external service needed
- User controls auth

**Cons:**
- User must run external tool (friction)
- ToS violations likely
- Session expiry (user must re-auth)
- Not kid-friendly

#### Option C: Official OAuth (Where Available)
```
User → OAuth flow → Access token → Roblox DataStore
Roblox Server → DataStore → HTTP calls with token → LLM API
```

**Pros:**
- Official, ToS-compliant
- No bot detection
- Token refresh handled

**Cons:**
- Limited provider support (Gemini, xAI only)
- Requires subscription

### Comparison

| Approach | ToS Compliance | Provider Support | Complexity | Kid-Friendly |
|----------|----------------|------------------|------------|--------------|
| **Browser hijacking** | ❌ Likely violates | ✅ Any provider | 🔴 High | ❌ No |
| **External auth service** | ❌ Likely violates | ✅ Any provider | 🔴 High | ⚠️ Maybe |
| **Official OAuth** | ✅ Compliant | ⚠️ Limited (Gemini, xAI) | 🟢 Low | ✅ Yes |

### Recommendation

**Browser session hijacking is not viable for Roblox:**
1. **ToS violations** — Unofficial API access likely violates provider ToS
2. **Bot detection** — Providers actively block automated access
3. **Not kid-friendly** — Requires running external tools or complex auth flows
4. **Session management** — Cookies expire, require re-auth
5. **Roblox constraints** — Cannot run browser automation on servers

**Official OAuth is the only viable approach for Roblox:**
- ToS-compliant
- Kid-friendly (browser-based auth)
- Limited provider support (Gemini, xAI)
- Lower complexity

### Decision

**Stick with official OAuth approach.** Browser session hijacking is technically interesting but not viable for:
- Roblox server constraints
- Kid-friendly UX
- ToS compliance
- Long-term maintainability
