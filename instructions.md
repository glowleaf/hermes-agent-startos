# Hermes Agent for StartOS

A personal AI assistant with Web UI that runs on your StartOS server.

## Setup

1. Go to **Config** and enter your:
   - **Provider**: Choose OpenRouter, Anthropic, DeepSeek, or Nous
   - **Model**: Enter the model name (e.g., `claude-sonnet-4`, `deepseek-chat`)
   - **API Key**: Your provider API key

2. Click **Start** to launch the service.

3. Open the **Web UI** to start chatting with your AI assistant.

## Getting API Keys

- **OpenRouter**: Create an account at https://openrouter.ai/ and generate a key
- **Anthropic**: Sign up at https://console.anthropic.com/ and create an API key
- **DeepSeek**: Register at https://platform.deepseek.com/ and get your API key
- **Nous**: Requires a Nous Research subscription

## Usage

Once started, the Hermes Agent Web UI is available at port 8787. You can access it through:
- **Tor**: Via the .onion address shown in the service properties
- **LAN**: Directly at `http://<your-startos-ip>:8787`

## Data

All chat history, configuration, and persistent memory are stored in the service's data volume. Backups include this data.

## Support

- Documentation: https://hermes-agent.nousresearch.com/docs/
- GitHub: https://github.com/NousResearch/hermes-agent
