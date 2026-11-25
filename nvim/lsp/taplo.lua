-- TOML; schemas (Cargo.toml, rustfmt.toml, ...) come from the SchemaStore catalog.
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
}
