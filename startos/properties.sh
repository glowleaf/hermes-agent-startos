#!/bin/bash
set -e

# Hermes Agent properties: outputs config spec + current values
CONFIG_FILE="/data/start9/config.json"

SPEC='{"provider":{"type":"enum","name":"Provider","description":"Model provider to use.","values":[{"value":"openrouter","description":"OpenRouter"},{"value":"anthropic","description":"Anthropic"},{"value":"deepseek","description":"DeepSeek"},{"value":"nous","description":"Nous"},{"value":"lmstudio","description":"LM Studio (local)"},{"value":"opencode-go","description":"OpenCode Go"}],"default":"openrouter"},"model":{"type":"string","name":"Model","description":"Model name for the selected provider.","default":"anthropic/claude-sonnet-4","nullable":false,"masked":false,"copyable":true,"pattern":".+"},"api_key":{"type":"string","name":"API Key","description":"API key for the selected provider (leave empty for LM Studio).","default":"","nullable":false,"masked":true,"copyable":false,"pattern":".*"},"base_url":{"type":"string","name":"Base URL","description":"Custom API base URL (e.g., http://192.168.1.52:1234 for LM Studio).","default":"","nullable":false,"masked":false,"copyable":true,"pattern":".*"},"memory":{"type":"boolean","name":"Memory","description":"Enable persistent memory across sessions.","default":true},"web_search":{"type":"boolean","name":"Web Search","description":"Enable web search tools.","default":true},"browser":{"type":"boolean","name":"Browser Automation","description":"Enable browser automation tools.","default":false}}'

if [ -f "$CONFIG_FILE" ]; then
  CONFIG=$(cat "$CONFIG_FILE")
  echo "{\"spec\": $SPEC, \"config\": $CONFIG}"
else
  echo "{\"spec\": $SPEC, \"config\": {}}"
fi
