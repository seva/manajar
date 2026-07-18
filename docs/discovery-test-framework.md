# Discovery: Test Framework

_Phase 0 artifact. Post-hoc reconstruction._

## Requirement

Run Luau tests for shared modules. Must support `describe`/`it`/`expect` BDD-style syntax.

## Options Evaluated

| Framework | Runtime | Status |
|-----------|---------|--------|
| Roblox TestService | Roblox Studio only | Viable for integration tests |
| testez (roblox-testing) | Roblox Studio via Rojo | Standard choice |
| lune-test | Standalone Luau | Not Studio-compatible |
| luau-analyze | Type-check only | Not a test framework |

## Decision

**Test runner: TBD** (listed in CLAUDE.md). Tests are written in Roblox-native BDD format (`describe`, `it`, `expect`) compatible with TestService and testez. Actual execution requires Roblox Studio or a Rojo-based test harness.

## Test Structure

```
tests/
└── Shared/
    ├── ManaJar/
    ├── ManaInput/
    ├── Targeting/
    ├── SpellCaster/
    ├── ManaScaling/
    ├── EffectApplier/
    └── Feedback/
```

Tests mirror `src/Shared/` structure. Each test file exports a function wrapping `describe`/`it` blocks:

```luau
return function()
    describe("ModuleName.FunctionName", function()
        it("should do something", function()
            -- test body
        end)
    end)
end
```

## Open Questions

- Should we add `lune` for CLI test runs outside Studio?
- testez vs bare TestService — testez provides better assertion output
- CI integration requires headless Roblox Studio runner

## Coverage

Not tracked yet. No coverage tooling exists for Luau in this project. Coverage will be assessed manually in Phase 2.
