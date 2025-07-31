-- UI-related plugin configurations
local M = {}

local keybind_docs = require("keybind_docs")
local pkgmgr = require("pkgmgr")

function M.setup_nvim_tree()
  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    view = {
      side = "left",
      width = 30,
    },
    renderer = {
      group_empty = true,
      highlight_git = true,
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
      },
    },
    filters = {
      dotfiles = false,
    },
    git = {
      enable = true,
      ignore = false,
    },
  })
end

function M.nvim_tree_keys()
  return {
    { "<leader>tt", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    { "<leader>tf", "<cmd>NvimTreeFindFile<cr>", desc = "Find current file in tree" },
  }
end

function M.nvim_tree_init()
  keybind_docs.document_keymap('n', '<leader>tt', 'Toggle file tree', 'NvimTree')
  keybind_docs.document_keymap('n', '<leader>tf', 'Find current file in tree', 'NvimTree')
end

function M.setup_lualine()
  require("lualine").setup({
    sections = {
      lualine_c = {
        {
          pkgmgr.cwd_root(),
          icon = "",
          padding = { left = 1, right = 1 },
        },
        {
          "filename",
          path = 1,
        }
      },
    },
  })
end

return M