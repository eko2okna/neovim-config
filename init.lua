-- init.lua for Neovim (minimal, warm colors, tree always open, toggle focus with Ctrl+n)

-- Ensure lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
  end
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup({
    -- File tree (left side, always open)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
    local nvim_tree = require("nvim-tree")
    local tree_api = require("nvim-tree.api")

    -- nvim-tree: left-side explorer, keep it open; default keymaps enabled
    nvim_tree.setup({
      view = { side = "left", width = 25 },
      update_focused_file = { enable = true },
      actions = {
        open_file = {
          quit_on_open = false, -- do not close the tree after opening a file
        },
      },
      -- No custom keymaps: rely on defaults (Enter to open, 'a' to add, etc.)
    })

    -- Automatically open the tree when Neovim starts
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
      tree_api.tree.open()
      end
    })

    -- Ctrl+n: toggle focus between tree and the last active window
    local focus_on_tree = false
    vim.keymap.set("n", "<C-n>", function()
    local view = tree_api.tree.get_node_under_cursor() or nil
    if focus_on_tree then
      -- go back to previous window
      vim.cmd('wincmd p')
      focus_on_tree = false
      else
        -- move focus to the tree
        tree_api.tree.focus()
        focus_on_tree = true
        end
        end, { noremap = true, silent = true })
    end
  },

  -- Colorscheme (warm purple/orange vibes)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- mocha has warm purples
      color_overrides = {
        mocha = {
          base = "#1d1b26",
          mantle = "#1a1822",
          crust = "#16141e",
          peach = "#ffb86c",
          lavender = "#cba6f7",
        }
      }
    })
    vim.cmd.colorscheme("catppuccin")
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
    })
    end
  },

  -- Lualine (warm theme)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
    require("lualine").setup({
      options = { theme = "catppuccin" },
    })
    end
  },

  -- LSP & completion ecosystem (installed via Mason; configured in lua/lsp.lua)
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip"
    },
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-null-ls.nvim"
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "nvimtools/none-ls.nvim", "williamboman/mason.nvim" },
  },
  })

  -- Load LSP/Completion configuration (defined in lua/lsp.lua)
  pcall(require, "lsp")

  -- Basic settings
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.termguicolors = true
