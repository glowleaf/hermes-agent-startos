import { VersionGraphAdapter, VersionInfo } from '@start9labs/start-sdk'

const v011: VersionInfo = {
  version: '0.1.1',
  name: 'Config UI + Official Branding Fix',
  notes:
    'Fixes empty StartOS Config page by packaging with Start SDK exports (config matcher/rules/env). Updates package icon to official Hermes branding.',
  longNotes: [
    'Fixes:',
    '- StartOS Config tab now shows Hermes options (provider, model, API key, memory, web search, browser)',
    '- Packaging switched to Start SDK `start-sdk pack .` flow so config schema is included correctly',
    '- Updated package icon to official Hermes branding',
    '',
    'No data migration required.',
  ].join('\n'),
}

const versions = VersionGraphAdapter.of(v011)
export const currentVersion = v011
export default versions
