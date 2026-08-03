return {
  'mistricky/codesnap.nvim',
  build = 'make build_generator',
  cmd = { 'CodeSnap', 'CodeSnapSave', 'CodeSnapHighlight', 'CodeSnapSaveHighlight' },
}
