import { types as T } from '@start9labs/start-sdk'
import { manifest } from './manifest'
import { currentVersion, versions } from './versions'
import { configMatcher, configRules, configToEnv, Config } from './config'
import { init } from './init'
import { i18n } from './i18n'

export { manifest, currentVersion, versions, configMatcher, configRules, configToEnv, init, i18n }
export type { Config }
