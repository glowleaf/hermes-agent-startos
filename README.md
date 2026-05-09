# hermes-agent-startos

**Hermes Agent** packaged as a StartOS service.

A personal AI assistant with Web UI that runs on your StartOS server. Supports multiple LLM providers (OpenRouter, Anthropic, DeepSeek, Nous) with persistent memory, web search, and browser automation.

## Quick Start

### Prerequisites
- StartOS 0.4.0+
- Docker
- Node.js 18+ and npm
- StartOS SDK: `npm install -g @start9labs/start-sdk`

### Build

```bash
npm install
npm run build        # Compiles TypeScript + builds Docker image
make s9pk           # Packages the .s9pk file
```

### Install on StartOS

1. Upload `hermes-agent.s9pk` via StartOS Marketplace → "Add Package"
2. Configure your API key and provider in the Config tab
3. Start the service
4. Access the Web UI at `http://<startos-ip>:8787`

## Configuration

| Setting       | Description                                      |
|---------------|--------------------------------------------------|
| Provider      | LLM provider: openrouter, anthropic, deepseek, nous |
| Model         | Model name (e.g., claude-sonnet-4, deepseek-v3)  |
| API Key       | Your provider API key                            |
| Memory        | Enable persistent memory across sessions         |
| Web Search    | Enable web search tools                          |
| Browser       | Enable browser automation                        |

## Architecture

- **Image**: Python 3.11 slim, Hermes Agent installed from PyPI
- **Web UI**: Exposed on port 8787
- **Data**: Persistent volume mounted at `/data`
- **Health**: HTTP check against Web UI

## Directory Structure

```
hermes-agent-startos/
├── Dockerfile              # Container image
├── entrypoint.sh           # First-run config + startup
├── Makefile                # s9pk build targets
├── package.json            # Node.js dependencies (start-sdk)
├── tsconfig.json           # TypeScript config
├── startos/
│   ├── index.ts            # Main SDK export
│   ├── config.ts           # Configuration schema
│   ├── manifest/
│   │   ├── index.ts        # Package manifest
│   │   └── i18n.ts         # Descriptions
│   ├── versions/
│   │   └── index.ts        # Version graph
│   ├── init/
│   │   ├── index.ts        # Init lifecycle
│   │   └── compat.ts       # Container definition
│   ├── i18n/
│   │   ├── index.ts
│   │   └── dictionaries/
│   └── utils.ts
└── README.md
```

## Usage

Once Hermes Agent is running on StartOS, access the Web UI at:

```
http://<startos-ip>:8787
```

### Configuring a Provider

1. Go to StartOS → Hermes Agent → Config
2. Select a **Provider**:
   - **OpenRouter** — connects to OpenRouter's API (supports 200+ models)
   - **Anthropic** — direct Anthropic API (Claude models)
   - **DeepSeek** — DeepSeek API
   - **Nous** — Nous Research API
   - **OpenAI** — OpenAI API (GPT models)
   - **OpenCode Go** — OpenCode API
   - **LM Studio** — connect to a local LM Studio instance on your network
   - **Custom** — any OpenAI-compatible endpoint
3. Enter your **Model** name (e.g. `anthropic/claude-sonnet-4`, `deepseek-v4-flash`, `qwen/qwen3.5-9b`)
4. For remote providers: enter your **API Key**
5. For local endpoints (LM Studio, Custom): enter the **Base URL** (e.g. `http://192.168.1.52:1234`)
6. Toggle features: **Memory**, **Web Search**, **Browser Automation**
7. Save — the service restarts automatically

### CLI Access (SSH into StartOS)

If you have SSH access to the StartOS server:

```bash
# Access the running container
sudo podman exec -it hermes-agent.1.0.1 /bin/bash

# Run Hermes commands directly
hermes --help
```

### Telegram Integration

Hermes Agent can connect to Telegram as a bot:

1. Create a bot via [@BotFather](https://t.me/botfather) and get a token
2. In the container, run:
   ```bash
   hermes telegram connect --token <your-bot-token>
   ```
3. The bot will appear in your Telegram and respond to commands

### Troubleshooting

**Web UI not loading**: Check StartOS → Hermes Agent → Logs. The container starts an HTTP server on port 8787.

**Config page shows an error**: Ensure you're on the latest s9pk build. Re-sideload from the [releases page](https://github.com/glowleaf/hermes-agent-startos/releases).

**Provider not connecting**: Verify API keys in Config. For LM Studio, confirm the instance is running and reachable at the Base URL you entered.

**Container keeps restarting**: Check logs for Python dependency errors or token limits.
```
