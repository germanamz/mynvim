-- Completion configuration
local M = {}

local keybind_docs = require("keybind_docs")

function M.setup()
  local cmp = require("cmp")

  cmp.setup({
    snippet = {
      expand = function(args) 
        require("luasnip").lsp_expand(args.body) 
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
      { name = "nvim_lsp" },
      {
        name = "buffer",
        option = {
          get_bufnrs = function() 
            return vim.api.nvim_list_bufs() 
          end
        }
      },
      { name = "path" },
      { name = "luasnip" },
    },
  })

  -- Document completion keybindings
  keybind_docs.document_keymap('i', '<C-Space>', 'Trigger completion', 'Completion')
  keybind_docs.document_keymap('i', '<CR>', 'Confirm completion', 'Completion')
end

return M