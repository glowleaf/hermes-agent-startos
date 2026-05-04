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
