-- Plugin manager setup and plugin list
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Core dependencies
  { "nvim-lua/plenary.nvim" },
  { "folke/neodev.nvim", opts = {} },

  -- UI and theming
  { "projekt0n/github-nvim-theme", priority = 1000 },
  { "nvim-lualine/lualine.nvim", opts = { theme = "auto" } },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function() require("plugins.ui").setup_nvim_tree() end,
    keys = function() return require("plugins.ui").nvim_tree_keys() end,
    init = function() require("plugins.ui").nvim_tree_init() end,
  },

  -- Treesitter and syntax
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function() require("plugins.treesitter").setup() end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  { "HiPhish/rainbow-delimiters.nvim" },

  -- Git integration
  { 
    "lewis6991/gitsigns.nvim", 
    config = function() require("plugins.git").setup_gitsigns() end,
  },

  -- LSP and completion
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { 
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip"
    },
    config = function() require("plugins.completion").setup() end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    config = function() require("plugins.telescope").setup() end,
    keys = function() return require("plugins.telescope").keys() end,
    init = function() require("plugins.telescope").init() end,
  },

  -- Formatting and linting
  { "stevearc/conform.nvim" },
  { "mfussenegger/nvim-lint" },

  -- Debugging
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", opts = {} },
  { "nvim-neotest/nvim-nio" },

  -- Utilities
  { "numToStr/Comment.nvim", opts = {} },
  { "ckipp01/stylua-nvim" },
})