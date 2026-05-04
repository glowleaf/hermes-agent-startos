const DEFAULT_CONFIG = {
  provider: 'openrouter',
  model: 'anthropic/claude-sonnet-4',
  base_url: '',
  api_key: '',
  memory: true,
  web_search: true,
  browser: false,
};

const SPEC = {
  provider: {
    type: 'enum',
    name: 'Provider',
    description: 'Model provider to use.',
    values: ['openrouter', 'anthropic', 'deepseek', 'nous', 'openai', 'openai-codex', 'lmstudio', 'custom'],
    'value-names': {
      openrouter: 'OpenRouter',
      anthropic: 'Anthropic',
      deepseek: 'DeepSeek',
      nous: 'Nous',
      openai: 'OpenAI',
      'openai-codex': 'OpenAI Codex',
      lmstudio: 'LM Studio',
      custom: 'Custom (OpenAI-compatible)',
    },
    default: 'openrouter',
  },
  model: {
    type: 'string',
    name: 'Model',
    description: 'Model name for the selected provider.',
    default: 'anthropic/claude-sonnet-4',
    nullable: false,
    masked: false,
    copyable: true,
    pattern: '.+',
    'pattern-description': 'Must not be empty.',
  },
  base_url: {
    type: 'string',
    name: 'Base URL',
    description: 'Optional API base URL (use for LM Studio or custom OpenAI-compatible endpoints).',
    default: '',
    nullable: false,
    masked: false,
    copyable: true,
    pattern: '.*',
    'pattern-description': 'Any URL string or empty.',
  },
  api_key: {
    type: 'string',
    name: 'API Key',
    description: 'API key for the selected provider.',
    default: '',
    nullable: false,
    masked: true,
    copyable: false,
    pattern: '.*',
    'pattern-description': 'Any string.',
  },
  memory: {
    type: 'boolean',
    name: 'Memory',
    description: 'Enable persistent memory across sessions.',
    default: true,
  },
  web_search: {
    type: 'boolean',
    name: 'Web Search',
    description: 'Enable web search tools.',
    default: true,
  },
  browser: {
    type: 'boolean',
    name: 'Browser Automation',
    description: 'Enable browser automation tools.',
    default: false,
  },
};

function normalizeConfig(input = {}) {
  return {
    provider: input.provider ?? DEFAULT_CONFIG.provider,
    model: input.model ?? DEFAULT_CONFIG.model,
    api_key: input.api_key ?? DEFAULT_CONFIG.api_key,
    base_url: input.base_url ?? DEFAULT_CONFIG.base_url,
    memory: input.memory ?? DEFAULT_CONFIG.memory,
    web_search: input.web_search ?? DEFAULT_CONFIG.web_search,
    browser: input.browser ?? DEFAULT_CONFIG.browser,
  };
}

export async function getConfig(effects) {
  let current = DEFAULT_CONFIG;
  try {
    const raw = await effects.readFile({ path: 'start9/config.json', volumeId: 'main' });
    current = normalizeConfig(JSON.parse(raw));
  } catch (_e) {
    current = DEFAULT_CONFIG;
  }

  return {
    result: {
      config: current,
      spec: SPEC,
    },
  };
}

export async function setConfig(effects, newConfig) {
  const cfg = normalizeConfig(newConfig || {});
  await effects.createDir({ path: 'start9', volumeId: 'main' });
  await effects.writeFile({
    path: 'start9/config.json',
    toWrite: JSON.stringify(cfg, null, 2),
    volumeId: 'main',
  });
  return {
    result: {
      signal: 'SIGTERM',
      'depends-on': {},
    },
  };
}

export async function properties() {
  return {};
}

export async function health(_effects) {
  return { status: 'passing', message: 'ok' };
}

export async function createBackup() {
  return {};
}

export async function restoreBackup() {
  return {};
}

export async function migration() {
  return { configured: true };
}
