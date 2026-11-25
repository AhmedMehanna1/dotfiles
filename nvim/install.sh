#!/bin/bash
# Links the config and installs the language servers/tools it expects. Safe to re-run.
set -euo pipefail

mkdir -p ~/.config
ln -vsfn ~/.dotfiles/nvim ~/.config/nvim

have() { command -v "$1" >/dev/null 2>&1; }

# C: clangd/clang-format/clang-tidy, bear (compile_commands.json from make), tree-sitter (parser builds)
have clangd && have bear && have tree-sitter || sudo dnf install -y clang-tools-extra bear tree-sitter-cli

# Rust
rustup component add rust-analyzer rust-src clippy rustfmt

# YAML / JSON (npm prefix is /usr/local, hence sudo)
have yaml-language-server || sudo npm install -g yaml-language-server
have vscode-json-language-server || sudo npm install -g vscode-langservers-extracted

# TOML
have taplo || cargo install --locked taplo-cli --features lsp

# Plugins + treesitter parsers (vim.pack installs on first start)
nvim --headless +'lua require("nvim-treesitter").install({ "c", "rust", "toml", "yaml", "json", "make", "markdown", "markdown_inline", "bash", "lua" }):wait(300000)' +qa
