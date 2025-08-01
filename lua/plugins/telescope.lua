-- Telescope configuration
local M = {}

local keybind_docs = require("keybind_docs")

function M.setup()
  local telescope = require("telescope")
  local actions = require("telescope.actions")

  telescope.setup({
    defaults = {
      prompt_prefix = "🔭 ",
      selection_caret = " ",
      initial_mode = "normal",
      mappings = {
        i = { 
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-j>"] = actions.move_selection_next 
        },
      },
    },
    extensions = {
      file_browser = { hijack_netrw = true },
    },
  })

  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "file_browser")
end

function M.keys()
  return {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({
          find_command = { "sh", "-c", "git ls-files --exclude-standard --others --cached; find . -name '.env*' -type f" },
          follow = true,
          hidden = true,
        })
      end,
      desc = "Find git files (tracked + untracked)",
    },
    {
      "<leader>ft",
      function() require("telescope.builtin").git_files() end,
      desc = "Find git files (tracked only)",
    },
    { "<leader>fa", "<cmd>Telescope find_files<cr>", desc = "Find all files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
    { 
      "<leader>fE", 
      function() 
        require("telescope").extensions.file_browser.file_browser({
          path = vim.fn.expand('%:p:h'),
          cwd = vim.fn.getcwd(),
          respect_gitignore = false,
        })
      end, 
      desc = "File browser (current buffer dir)" 
    },
  }
end

function M.init()
  -- Document Telescope keybindings
  keybind_docs.document_keymap('n', '<leader>ff', 'Find git files (tracked + untracked + .env files)', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>ft', 'Find git files (tracked only)', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fa', 'Find all files', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fg', 'Live grep', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fb', 'Buffers', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fh', 'Help tags', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fe', 'File browser', 'Telescope')
  keybind_docs.document_keymap('n', '<leader>fE', 'File browser (current buffer directory)', 'Telescope')
  keybind_docs.document_keymap('i', '<C-k>', 'Move selection up', 'Telescope Internal Mappings')
  keybind_docs.document_keymap('i', '<C-j>', 'Move selection down', 'Telescope Internal Mappings')
end

return M