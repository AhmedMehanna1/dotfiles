-- Neovim 0.12+ config for C, Rust, YAML/JSON/TOML, Makefile.
-- Language servers live in lsp/*.lua, per-filetype tweaks in after/ftplugin/.
-- Keymaps mirror ~/.ideavimrc so JetBrains muscle memory carries over.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options ---------------------------------------------------------------------
local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.ignorecase = true
o.smartcase = true
o.cursorline = true
o.scrolloff = 5
o.signcolumn = 'yes'
o.swapfile = false
o.undofile = true
o.clipboard = 'unnamedplus'
o.splitright = true
o.splitbelow = true
o.updatetime = 300
o.completeopt = { 'menuone', 'noselect', 'popup', 'fuzzy' }
o.wildignore:append({ '*/target/*', '*/.git/*', '*.o' })
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Plugins (built-in vim.pack; update with :lua vim.pack.update()) -------------
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind ~= 'delete' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/igorlfs/nvim-dap-view',
}, { confirm = false })

vim.cmd.colorscheme('tokyonight-night')

-- Treesitter: install parsers, enable highlight + indent where a parser exists
local parsers = { 'c', 'rust', 'toml', 'yaml', 'json', 'make', 'markdown', 'markdown_inline', 'bash', 'lua' }
require('nvim-treesitter').install(parsers)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- mini.nvim: picker, file explorer, surround, git signs, statusline, key hints
require('mini.icons').setup()
require('mini.pick').setup()
require('mini.extra').setup()
-- Enter opens file and closes explorer (default was L); l/h still step in/out
require('mini.files').setup({ mappings = { go_in_plus = '<CR>' } })
require('mini.surround').setup()
require('mini.pairs').setup()
-- Rust lifetimes ('a) make ' pairing a nuisance
vim.api.nvim_create_autocmd('FileType', { pattern = 'rust', callback = function() vim.keymap.set('i', "'", "'", { buffer = true }) end })
require('mini.diff').setup()
require('mini.git').setup()
require('mini.statusline').setup()
local clue = require('mini.clue')
clue.setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' }, { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' }, { mode = 'n', keys = '[' }, { mode = 'n', keys = ']' },
    { mode = 'n', keys = '<C-w>' }, { mode = 'n', keys = 'z' },
  },
  clues = {
    { mode = 'n', keys = '<Leader>f', desc = '+find' },
    { mode = 'n', keys = '<Leader>d', desc = '+debug' },
    { mode = 'n', keys = '<Leader>c', desc = '+code/build' },
    { mode = 'n', keys = '<Leader>x', desc = '+run/close' },
    { mode = 'n', keys = '<Leader>s', desc = '+split/symbols' },
    { mode = 'n', keys = '<Leader>g', desc = '+goto' },
    { mode = 'n', keys = '<Leader>r', desc = '+refactor' },
    { mode = 'n', keys = '<Leader>e', desc = '+explorer' },
    clue.gen_clues.g(), clue.gen_clues.windows(), clue.gen_clues.z(),
  },
  window = { delay = 300 },
})

-- LSP -------------------------------------------------------------------------
vim.lsp.enable({ 'clangd', 'rust_analyzer', 'yamlls', 'jsonls', 'taplo' })

vim.g.autoformat = true -- :let g:autoformat = v:false to stop format-on-save
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local buf = ev.buf

    -- Complete as you type (not only after '.' / '::'): every char is a trigger
    local cp = client.server_capabilities.completionProvider
    if cp then
      local chars = {}
      for c in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_.:>'):gmatch('.') do table.insert(chars, c) end
      cp.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    if client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = buf,
        callback = function()
          if vim.g.autoformat then vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 2000 }) end
        end,
      })
    end
  end,
})

-- Enter accepts the highlighted completion item, otherwise newline (splits {|} pairs)
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or MiniPairs.cr()
end, { expr = true })

-- Debugger: gdb >= 14 speaks DAP natively, works for both C and Rust ---------
local dap, dv = require('dap'), require('dap-view')
dv.setup()
dap.listeners.before.launch['dap-view'] = function() dv.open() end
dap.listeners.before.event_terminated['dap-view'] = function() dv.close() end
dap.adapters.gdb = { type = 'executable', command = 'gdb', args = { '--interpreter=dap', '--eval-command', 'set print pretty on' } }
-- rust-gdb is gdb plus Rust pretty-printers (Vec, String, ...)
dap.adapters['rust-gdb'] = { type = 'executable', command = 'rust-gdb', args = { '--interpreter=dap', '--eval-command', 'set print pretty on' } }

local function pick_program(default)
  return function() return vim.fn.input('Executable: ', default(), 'file') end
end
dap.configurations.c = { {
  name = 'Launch', type = 'gdb', request = 'launch', cwd = '${workspaceFolder}',
  program = pick_program(function() return vim.fn.getcwd() .. '/' end),
} }
dap.configurations.rust = { {
  name = 'Launch', type = 'rust-gdb', request = 'launch', cwd = '${workspaceFolder}',
  program = pick_program(function()
    return vim.fn.getcwd() .. '/target/debug/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  end),
} }

-- Build / run -----------------------------------------------------------------
-- Cargo project -> cargo; otherwise make. shortcut: C "run" assumes a `make run` target.
local function in_cargo() return vim.fs.root(0, 'Cargo.toml') ~= nil end
local function run_in_term(cmd)
  vim.cmd('botright split | resize 15 | terminal ' .. cmd)
  vim.cmd.startinsert()
end

-- Window move that falls through to tmux at the edge (tmux.conf has the other half)
local function nav(dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)
    if win == vim.api.nvim_get_current_win() and vim.env.TMUX then
      vim.fn.system({ 'tmux', 'select-pane', '-' .. ({ h = 'L', j = 'D', k = 'U', l = 'R' })[dir] })
    end
  end
end

-- Keymaps (mirroring ideavimrc) -----------------------------------------------
local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc }) end
local pick, extra = MiniPick.builtin, MiniExtra.pickers

-- Find
map('n', '<Leader>ff', pick.files, 'Files')
map('n', '<Leader>fa', pick.files, 'Files')
map('n', '<Leader>fs', pick.grep_live, 'Grep')
map('n', '<Leader>fS', function() extra.lsp({ scope = 'workspace_symbol' }) end, 'Workspace symbols')
map('n', '<Leader>fr', extra.oldfiles, 'Recent files')
map('n', '<Leader>fb', pick.buffers, 'Buffers')
map('n', '<Leader>fd', extra.diagnostic, 'Diagnostics')
map('n', '<Leader>fh', pick.help, 'Help')
map('n', '<Leader>ss', function() extra.lsp({ scope = 'document_symbol' }) end, 'Document symbols')

-- Code navigation (built-ins also exist: grr, gri, grn, gra, gO, K, [d ]d)
map('n', 'gd', vim.lsp.buf.definition, 'Definition')
map('n', '<Leader>gd', vim.lsp.buf.definition, 'Definition')
map('n', '<Leader>gi', vim.lsp.buf.implementation, 'Implementation')
map('n', '<Leader>gs', vim.lsp.buf.type_definition, 'Type definition')
map('n', '<Leader>su', function() extra.lsp({ scope = 'references' }) end, 'Usages')

-- Editing / refactoring
vim.keymap.set('x', '<Leader>/', 'gc', { remap = true, desc = 'Comment' })
vim.keymap.set('n', '<Leader>/', 'gcc', { remap = true, desc = 'Comment' })
map('n', '<Leader>cf', function() vim.lsp.buf.format() end, 'Format')
map({ 'n', 'x' }, '<Leader>ca', vim.lsp.buf.code_action, 'Code action')
map('n', '<Leader>re', vim.lsp.buf.rename, 'Rename')
map('n', '<Leader>hb', function() MiniGit.show_at_cursor() end, 'Git history at cursor')
map('n', '<C-j>', '<Cmd>move .+1<CR>==', 'Move line down')
map('n', '<C-k>', '<Cmd>move .-2<CR>==', 'Move line up')
map('i', '<C-j>', '<Esc><Cmd>move .+1<CR>==gi', 'Move line down')
map('i', '<C-k>', '<Esc><Cmd>move .-2<CR>==gi', 'Move line up')
map('x', '<C-j>', ":move '>+1<CR>gv=gv", 'Move selection down')
map('x', '<C-k>', ":move '<-2<CR>gv=gv", 'Move selection up')

-- Windows / explorer
map('n', '<Leader>sv', '<Cmd>vsplit<CR>', 'Split vertically')
map('n', '<Leader>sh', '<Cmd>split<CR>', 'Split horizontally')
map('n', '<C-h>', nav('h'), 'Window left')
map('n', '<C-l>', nav('l'), 'Window right')
map('n', '<Leader>ee', function() MiniFiles.open() end, 'File explorer')
map('n', '<Leader>ef', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, 'Reveal file')
map('n', '<Leader>xo', '<Cmd>%bdelete|edit#|bdelete#<CR>', 'Close other buffers')
map('n', '<C-Enter>', function() run_in_term(vim.o.shell) end, 'Terminal')
map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Leave terminal mode')

-- Debug
map('n', '<Leader>tb', dap.toggle_breakpoint, 'Toggle breakpoint')
map('n', '<Leader>ds', dap.continue, 'Debug start/continue')
map('n', '<Leader>dr', dap.continue, 'Resume')
map('n', '<Leader>dn', dap.step_over, 'Step over')
map('n', '<Leader>di', dap.step_into, 'Step into')
map('n', '<Leader>do', dap.step_out, 'Step out')
map('n', '<Leader>dt', dap.run_to_cursor, 'Run to cursor')
map('n', '<Leader>dq', dap.terminate, 'Stop debugging')
map({ 'n', 'x' }, '<Leader>de', function() require('dap.ui.widgets').hover() end, 'Evaluate')

-- Build / run
map('n', '<Leader>cc', function()
  vim.cmd(in_cargo() and 'compiler cargo | make build' or 'make')
  vim.cmd('cwindow')
end, 'Build')
map('n', '<Leader>xr', function() run_in_term(in_cargo() and 'cargo run' or 'make run') end, 'Run')
map('n', '<Leader>xt', function() run_in_term(in_cargo() and 'cargo test' or 'make test') end, 'Test')
