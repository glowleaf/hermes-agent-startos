import { matches, types as T, YAML } from '@start9labs/start-sdk'

const { string, choice, shape, boolean } = matches

export type Config = {
  provider: 'openrouter' | 'anthropic' | 'deepseek' | 'nous'
  model: string
  api_key: string
  memory: boolean
  web_search: boolean
  browser: boolean
}

export const configMatcher: T.ExpectedExports['properties'] = shape({
  provider: choice('openrouter', 'anthropic', 'deepseek', 'nous'),
  model: string,
  api_key: string,
  memory: boolean,
  web_search: boolean,
  browser: boolean,
})

export const configRules: T.ExpectedExports['rules'] = [
  { mask: '**', rule: { result: 'no-effect', reason: 'No rules needed' } },
]

// Translate the config object into env vars for the entrypoint.
export function configToEnv(config: Config): Record<string, string> {
  const env: Record<string, string> = {
    HERMES_MODEL_PROVIDER: config.provider,
    HERMES_MODEL_DEFAULT: config.model,
    HERMES_MEMORY_ENABLED: String(config.memory),
    HERMES_WEB_SEARCH_ENABLED: String(config.web_search),
    HERMES_BROWSER_ENABLED: String(config.browser),
  }

  switch (config.provider) {
    case 'openrouter':
      env['OPENROUTER_API_KEY'] = config.api_key
      break
    case 'anthropic':
      env['ANTHROPIC_API_KEY'] = config.api_key
      break
    case 'deepseek':
      env['DEEPSEEK_API_KEY'] = config.api_key
      break
    case 'nous':
      env['NOUS_API_KEY'] = config.api_key
      break
  }

  return env
}
