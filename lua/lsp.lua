-- lsp.lua
-- Provides language server (LSP) setup, completion (nvim-cmp), diagnostics UI,
-- linting/formatting with none-ls (prettier/stylua/eslint_d), and sensible keymaps.

-- Completion setup (nvim-cmp + LuaSnip snippets)
local has_cmp, cmp = pcall(require, 'cmp')
if has_cmp then
  local has_luasnip, luasnip = pcall(require, 'luasnip')
  if has_luasnip then
    require('luasnip.loaders.from_vscode').lazy_load()
  end
  cmp.setup({
    snippet = {
      expand = function(args)
        if has_luasnip then luasnip.lsp_expand(args.body) end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item() else fallback() end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item() else fallback() end
      end, { 'i', 's' }),
    }),
    -- Completion sources: LSP + snippets first, then buffer/path
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  })
end

-- LSP servers via Mason (automatic install + setup handlers)
local has_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')

-- Enhance LSP capabilities for completion (so servers know cmp is available)
local capabilities = vim.lsp.protocol.make_client_capabilities()
if has_cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Buffer-local LSP keymaps when a server attaches
local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Diagnostics UI: virtual text, signs, underline, sorting
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = '●' },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Diagnostic sign icons in the gutter
local signs = { Error = '', Warn = '', Hint = '', Info = '' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- Servers to configure; Mason installer will ensure these if available
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { 'vim' } },
        workspace = { checkThirdParty = false },
        format = { enable = true },
      }
    }
  },
  -- TypeScript/JavaScript: prefer ts_ls (typescript-language-server) in newer lspconfig.
  -- If your environment exposes only tsserver, a fallback below will configure it too.
  ts_ls = {},
  pyright = {},
  jsonls = {},
  html = {},
  cssls = {},
}

if has_mason_lspconfig and has_lspconfig then
  -- Only request installation for servers that Mason actually knows about
  local available = mason_lspconfig.get_available_servers()
  local avail_set = {}
  for _, name in ipairs(available) do avail_set[name] = true end
  local ensure = {}
  for name, _ in pairs(servers) do
    if avail_set[name] then table.insert(ensure, name) end
  end
  mason_lspconfig.setup({ ensure_installed = ensure })
  mason_lspconfig.setup_handlers({
    function(server_name)
      local server_opts = servers[server_name] or {}
      server_opts.capabilities = capabilities
      server_opts.on_attach = on_attach
      lspconfig[server_name].setup(server_opts)
    end,
  })
  -- Backward-compat: configure tsserver if it's present (older setups)
  if lspconfig.tsserver and not servers.tsserver then
    lspconfig.tsserver.setup({ capabilities = capabilities, on_attach = on_attach })
  end
end

-- Formatting & linting via none-ls (aka null-ls fork)
local has_null, null_ls = pcall(require, 'null-ls') -- if using old name
if not has_null then
  has_null, null_ls = pcall(require, 'none-ls') -- new fork name
end
local has_mason_null_ls, mason_null_ls = pcall(require, 'mason-null-ls')

if has_null then
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics
  null_ls.setup({
    sources = {
      formatting.prettier.with({ extra_args = { '--single-quote', '--jsx-single-quote' } }),
      formatting.stylua,
      diagnostics.eslint_d,
    },
    -- Enable format-on-save where supported
    on_attach = function(client, bufnr)
      if client.supports_method('textDocument/formatting') then
        local grp = vim.api.nvim_create_augroup('LspFormatOnSave', { clear = false })
        vim.api.nvim_clear_autocmds({ group = grp, buffer = bufnr })
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = grp,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    end,
  })
end

if has_mason_null_ls and has_null then
  mason_null_ls.setup({
    ensure_installed = { 'prettier', 'stylua', 'eslint_d' },
    automatic_installation = true,
  })
end

-- Show diagnostics in a floating window when the cursor is idle
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    local opts = { focusable = false, close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' }, border = 'rounded', source = 'always', prefix = ' ', scope = 'cursor' }
    pcall(vim.diagnostic.open_float, nil, opts)
  end,
})
