# Discovery: Roblox Luau

_Phase 0 artifact. Post-hoc reconstruction._

## Module System

Roblox Luau uses `require()` with script-based module resolution:

```luau
-- Module pattern
local MyModule = {}

function MyModule.DoSomething()
end

return MyModule

-- Import
local MyModule = require(path.To.MyModule)
```

All source is organized in a Rojo-compatible `src/` tree mapping to Roblox services:
- `src/Shared/` → `ReplicatedStorage` (shared modules)
- `src/Server/` → `ServerScriptService` (server-side scripts)
- `src/Client/` → `StarterPlayer/StarterPlayerScripts` (client-side scripts)

## Key Roblox Services Used

| Service | Purpose |
|---------|---------|
| ReplicatedStorage | Shared module storage |
| HttpService | Outbound HTTPS for LLM calls (server-side) |
| RunService | Heartbeat/Stepped for input accumulation |
| Players | Player management |
| TestService | Running tests |

## Type System

Luau supports structural types, union types, and generics. Key patterns used:
- `export type` for public type definitions
- `Type?` for nullable values
- `(boolean, string?)` for fallible operations
- `string | nil` for optional fields

## Rojo

Rojo syncs a filesystem tree to a Roblox place file. Standard config places `src/` at the root of the hierarchy. Not yet configured — requires `rojo.json` and manual setup.

## Naming Conventions

- PascalCase for modules and types
- camelCase for functions and variables
- `_spec` suffix for test files
- One module per directory with `init.luau` as entry point

## Open Questions

- Rojo version (0.7.x vs 0.6.x API differences)
- Whether to use Rojo live sync or one-time build
- Whether to version the `.rbxl` file or generate it from source only
