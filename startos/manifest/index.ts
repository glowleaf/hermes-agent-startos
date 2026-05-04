import { setupManifest } from '@start9labs/start-sdk'
import { long, short } from './i18n'

export const manifest = setupManifest({
  id: 'hermes-agent',
  title: 'Hermes Agent',
  license: 'MIT',
  packageRepo: 'https://github.com/glowleaf/hermes-agent-startos',
  upstreamRepo: 'https://github.com/NousResearch/hermes-agent',
  marketingUrl: 'https://hermes-agent.nousresearch.com/',
  donationUrl: null,
  docsUrls: ['https://hermes-agent.nousresearch.com/docs/'],
  description: { short, long },
  volumes: ['main'],
  images: {
    'hermes-agent': {
      source: { dockerBuild: '.' },
      arch: ['x86_64', 'aarch64'],
    },
  },
  alerts: {
    install: null,
    update: null,
    uninstall: null,
    restore: null,
    start: null,
    stop: null,
  },
  dependencies: {},
})
