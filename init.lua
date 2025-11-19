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

    nvim_tree.setup({
      view = { side = "left", width = 25 },
      update_focused_file = { enable = true },
      actions = {
        open_file = {
          quit_on_open = false, -- do not close after opening a file
        },
      },
    })

    -- automatic tree open after Neovim start
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
      tree_api.tree.open()
      end
    })

    -- Ctrl+n: toggle focus between tree and last buffer
    local focus_on_tree = false
    vim.keymap.set("n", "<C-n>", function()
    local view = tree_api.tree.get_node_under_cursor() or nil
    if focus_on_tree then
      -- go back to previous buffer
      vim.cmd('wincmd p')
      focus_on_tree = false
      else
        -- focus on tree
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
  })

  -- Basic settings
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.termguicolors = true
