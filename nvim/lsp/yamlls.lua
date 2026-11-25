-- schemaStore auto-matches GitHub Actions, docker-compose, etc. by filename.
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = { format = { enable = true }, schemaStore = { enable = true } },
  },
}
