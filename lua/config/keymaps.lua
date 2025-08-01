-- Global keymaps
local keybind_docs = require("keybind_docs")

-- Visual mode indentation
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

-- Buffer navigation keymaps
vim.keymap.set("n", "<leader>bb", function()
  local count = vim.v.count
  if count > 0 then
    vim.cmd("b" .. count)
  else
    vim.ui.input({ prompt = "Buffer number: " }, function(input)
      if input and input ~= "" then
        local bufnum = tonumber(input)
        if bufnum then
          vim.cmd("b" .. bufnum)
        end
      end
    end)
  end
end, { desc = "Switch to buffer by number (use count or prompt)" })

vim.keymap.set("n", "<leader>bd", require('util.buffer').smart_delete, { desc = "Delete current buffer (go to previous)" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic: show line message" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Document keybindings
keybind_docs.document_keymap('v', '<Tab>', 'Indent selection', 'Visual Mode')
keybind_docs.document_keymap('v', '<S-Tab>', 'Dedent selection', 'Visual Mode')
keybind_docs.document_keymap('n', '<leader>bb', 'Switch to buffer by number (5<leader>bb or prompts)', 'Buffer Navigation')
keybind_docs.document_keymap('n', '<leader>bd', 'Delete current buffer (go to previous)', 'Buffer Navigation')
keybind_docs.document_keymap('n', '<leader>e', 'Show diagnostic message for current line', 'Diagnostics')
keybind_docs.document_keymap('n', '[d', 'Previous diagnostic', 'Diagnostics')
keybind_docs.document_keymap('n', ']d', 'Next diagnostic', 'Diagnostics')