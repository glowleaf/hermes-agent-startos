import { createBackupSpec, expect, MigrationType } from '@start9labs/start-sdk'

const { to, from } = createBackupSpec(expect(0), '0.1.0')

// No migrations needed yet.
export const migrations: MigrationType = { to, from }
