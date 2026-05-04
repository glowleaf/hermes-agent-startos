import { types as T, initContainer } from '@start9labs/start-sdk'
import { createBackup, restoreBackup } from './compat'

export { createBackup, restoreBackup }

// Define the Docker container for the Hermes Agent service
export const init: initContainer = {
  image: { type: 'start9', packageId: 'hermes-agent', imageId: 'hermes-agent' },
  volumes: {
    '/data': 'main',
  },
  env: {
    HOME: '/data',
    HERMES_HOME: '/data/.hermes',
    HERMES_DATA_DIR: '/data/.hermes',
    NO_COLOR: '1',
  },
  ports: {
    '8787': 8787,
  },
  health: {
    kind: 'http',
    url: 'http://127.0.0.1:8787/',
    success: 200,
  },
  ready: {
    display: 'Web UI',
    description: 'The web interface of Hermes Agent',
    success: {
      kind: 'http',
      url: 'http://127.0.0.1:8787/',
      success: 200,
    },
  },
}
