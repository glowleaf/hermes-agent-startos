// Backup/restore stubs — no-op for now
export function createBackup() {
  return { backup: async () => {} }
}

export function restoreBackup() {
  return { restore: async () => {} }
}
