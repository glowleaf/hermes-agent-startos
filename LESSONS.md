# Hermes Agent on StartOS — Lessons Learned

## Config Format: `embassy.js`

StartOS 0.3.5.x requires enum `values` as a **flat string array** with a separate
`value-names` map. The object format (`[{value, description}]`) causes
`Config Generation Error: Couldn't convert output`.

### ✅ Correct format:
```javascript
values: ['openrouter', 'anthropic', 'deepseek', 'nous', 'openai', 'opencode-go', 'lmstudio', 'custom'],
'value-names': {
  openrouter: 'OpenRouter',
  anthropic: 'Anthropic',
  deepseek: 'DeepSeek',
  nous: 'Nous',
  openai: 'OpenAI',
  'opencode-go': 'OpenCode Go',
  lmstudio: 'LM Studio',
  custom: 'Custom (OpenAI-compatible)',
},
```

### ❌ Wrong format (crashes config page):
```javascript
values: [
  { value: 'openrouter', description: 'OpenRouter' },
  // ...
],
```

### `result` wrapper required

The `getConfig` function MUST return `{ result: { config, spec } }`, NOT
`{ config, spec }`. Missing `result` produces `RPC ERROR: Invalid Request
Invalid ID`.

```javascript
export async function getConfig(effects) {
  return {
    result: {    // ← REQUIRED wrapper
      config: current,
      spec: SPEC,
    },
  };
}
```

## Config → Container: Two Approaches

### Approach 1: `configToEnv()` (TypeScript SDK, preferred)

The TypeScript SDK's `configToEnv()` maps config fields to environment variables
that the entrypoint can read. This is the cleanest approach — the config is
injected as env vars when the container starts.

```typescript
export function configToEnv(config: Config): Record<string, string> {
  return {
    HERMES_MODEL_PROVIDER: config.provider,
    HERMES_MODEL_DEFAULT: config.model,
    HERMES_BASE_URL: config.base_url,
    // API keys mapped per-provider
  };
}
```

### Approach 2: Entrypoint reads config.json (script-based fallback)

When using the legacy script-based path (no TypeScript SDK), the entrypoint must
read `/data/start9/config.json` directly and apply it via `hermes config set`.

```bash
CONFIG_FILE="/data/start9/config.json"
if [ -f "$CONFIG_FILE" ]; then
  PROVIDER=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('provider',''))")
  hermes config set model.provider "$PROVIDER"
fi
```

**Important:** This config.json is written by `embassy.js`'s `setConfig()` to
the persistent data volume (`/data/start9/config.json`). It survives container
restarts.

## Port Forwarding (8787)

The `interfaces` section in `manifest.yaml` is required for the Web UI to be
accessible:

```yaml
interfaces:
  main:
    name: Web UI
    tor-config:
      port-mapping:
        "8787": "8787"
    lan-config:
      "8787":
        ssl: false
        internal: 8787
    ui: true
    protocols:
      - tcp
      - http
```

If the interface config exists but the port doesn't work:
1. Check that the container is running on the `start9` podman network
2. Verify with `curl http://<container-ip>:8787/` (inside the container)
3. If container is healthy but host port doesn't respond, restart startd:
   `sudo systemctl restart startd.service`
4. As a workaround, add an iptables DNAT rule:
   `iptables -t nat -A PREROUTING -p tcp --dport 8787 -j DNAT --to-destination <container-ip>:8787`

## Container Immutability

**Changes made inside the container (via `podman exec` or `podman cp`) are LOST
on restart.** The container is launched from the image every time startd starts
it. Only the mounted data volume (`/data`) persists.

To make permanent changes:
1. Modify the source files in the repo
2. Rebuild the Docker image
3. Repack the s9pk
4. Sideload the new s9pk onto StartOS

## Diagnostic Restart May Revert Hotfixes

Running `diagnostic.restart` on the StartOS API triggers a full system rebuild.
This may:
- Re-unpack the s9pk from the archive, overwriting any hotfixed files
- Reset SSH authorized keys (need to re-add via Settings → SSH Keys)
- Recreate the `br-start9` podman bridge
- Cause a full server reboot

## Health Checks

The health check uses an HTTP GET to `http://127.0.0.1:8787/` expecting status
200. This runs INSIDE the container, so it tests the Hermes dashboard directly.

```yaml
health-checks:
  web-ui:
    type: docker
    entrypoint: /usr/local/bin/health-check.sh
```

The health check script is simple:
```bash
#!/bin/bash
curl -sf http://127.0.0.1:8787/ > /dev/null 2>&1
exit $?
```

## API Key Masking

`embassy.js`'s `normalizeConfig()` treats `***` as the masked API key sent by
the StartOS UI (the actual key is never returned to the frontend after
initial save). The real key is stored in the config.json on disk and passed
to the container via env vars or the entrypoint.

## Building the S9PK

This repo supports TWO build paths:

### Legacy (script-based) — currently deployed
Uses `embassy.js` + shell scripts in `scripts/`. Built with the old StartOS
SDK CLI (not included in this repo).

### TypeScript SDK — future
Uses `startos/` TypeScript sources compiled with `@start9labs/start-sdk`.
Build with:
```bash
npm install
npm run build    # compiles startos/ → dist/
start-sdk pack . # produces .s9pk
```

## Updating Hermes Agent (Update Action)

The `Update Hermes Agent` action in the StartOS UI:
1. Pulls the latest source from `https://github.com/NousResearch/hermes-agent` 
   (upstream repo, NOT this wrapper repo)
2. Reinstalls the Python package with `pip install -e .`
3. Rebuilds the Web UI with `npm run build`
4. Restarts the gateway service

The update is applied on top of the immutable container — it persists in the
container's overlay filesystem until the container is restarted. To make the
update permanent, rebuild the s9pk from this repo after testing.
