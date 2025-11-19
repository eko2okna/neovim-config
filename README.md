<div align="center">

<a href="https://github.com/eko2okna">
  <img alt="Follows" src="https://img.shields.io/github/followers/eko2okna?label=Follows&style=social" />
</a>
<a href="https://github.com/eko2okna/neovim-config/stargazers">
  <img alt="GitHub stars" src="https://img.shields.io/github/stars/eko2okna/neovim-config?style=social" />
</a>
<a href="https://github.com/eko2okna/neovim-config/graphs/commit-activity">
  <img alt="Commit activity" src="https://img.shields.io/github/commit-activity/m/eko2okna/neovim-config" />
</a>
<a>
  <img src="https://img.shields.io/github/repo-size/eko2okna/neovim-config?style=flat-square" />
</a>
<a>
  <img alt="Linux" src="https://img.shields.io/badge/Linux-%23.svg?style=flat-square&logo=linux&color=FCC624&logoColor=black" />
</a>
<img alt="Neovim" src="https://img.shields.io/badge/Neovim-0.11.5-57A143?logo=neovim&logoColor=57A143" />


# Neovim: Minimal, Warm, Productive

Left-side file tree that stays open, warm Catppuccin theme, Treesitter, and a complete LSP + completion + formatting setup — fast to install, easy to extend.

</div>

## Highlights
- Always-open file tree on the left (`nvim-tree`).
- Warm UI: Catppuccin (mocha) with subtle overrides.
- Treesitter highlighting/indent and a themed statusline.
- LSP with completion, hover, go-to, rename, code actions.
- Formatting on save + linting via none-ls (prettier, stylua, eslint_d).

## Requirements
- Neovim 0.11+ recommended
- Git (for plugin manager bootstrapping)
- Optional per-language tools:
  - Node.js (useful for `prettier` / `eslint_d`)
  - Python (if you use pyright/formatters on Python projects)

## Install
You can copy this config directly into your Neovim folder:

```bash
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/
mkdir -p ~/.config/nvim/lua
cp -r lua ~/.config/nvim/
```

Then launch Neovim — the plugin manager (lazy.nvim) will auto-install everything:

```vim
:Lazy
```

Install/update language tools:

```vim
:Mason
:TSUpdate
```

## Keymaps (Essentials)
- Tree focus toggle: `<C-n>`
- Open file in tree: `Enter`
- Create/rename/delete in tree: `a` / `r` / `d` (use `A` to add at root)
- Split open from tree: `v` (vertical) / `s` (horizontal)
- LSP navigation: `gd` (definition), `gD` (declaration), `gI` (impl), `gr` (refs)
- LSP actions: `K` (hover), `<leader>rn` (rename), `<leader>ca` (code action)
- Diagnostics: `[d` / `]d` (prev/next)
- Formatting: `<leader>f` (manual); also runs on save where supported
- Completion: `<C-Space>` (trigger), `<CR>` (confirm), `Tab`/`S-Tab` (navigate)

## LSP & Tools
- Servers are declared in `lua/lsp.lua` under `servers`.
  - Defaults: `lua_ls`, `ts_ls` (TypeScript), `pyright`, `jsonls`, `html`, `cssls`.
  - Fallback: if your system exposes only `tsserver`, this config will set it up automatically.
- Mason ensures/install servers where available and wires them via handlers.
- none-ls (null-ls fork) provides formatters/linters: `prettier`, `stylua`, `eslint_d` by default.

## Project Structure
- `init.lua` — UI/theme, tree, statusline, plugin specs; LSP plugins declared here; loads `lua/lsp.lua`.
- `lua/lsp.lua` — completion (nvim-cmp + LuaSnip), diagnostics UI, LSP servers, Mason handlers, none-ls formatting on save.

## Update
Keep plugins and tools fresh:

```vim
:Lazy sync
:Mason
:TSUpdate
```

## Customize
- Add servers: edit `servers` in `lua/lsp.lua` (e.g., `rust_analyzer`, `gopls`).
- Extend formatters/linters: tweak `null_ls.setup({ sources = { ... } })`.
- Change colors: adjust Catppuccin flavour/overrides in `init.lua`.
- Keymaps: modify LSP maps in `lua/lsp.lua`; tree/UI maps in `init.lua`.

## Troubleshooting
- Tree Enter not opening files: defaults are used by design; restart or `:source $MYVIMRC`.
- TypeScript server mismatch: prefer `ts_ls`; if only `tsserver` exists, it is configured automatically.
- Format-on-save doesn’t run: ensure a formatter is installed in Mason and that the client supports `textDocument/formatting`.

---

If you use this config, open an issue/PR with ideas to improve ergonomics for common language stacks. Enjoy! 🎯
