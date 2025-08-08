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
vim.keymap.set("n", "<leader>bD", function()
  vim.ui.input({ prompt = "Close all buffers? [y/N]: " }, function(input)
    if input and (input:lower() == "y" or input:lower() == "yes") then
      require('util.buffer').close_all()
    end
  end)
end, { desc = "Close all buffers (with confirmation)" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic: show line message" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Document keybindings
keybind_docs.document_keymap('v', '<Tab>', 'Indent selection', 'Visual Mode')
keybind_docs.document_keymap('v', '<S-Tab>', 'Dedent selection', 'Visual Mode')
keybind_docs.document_keymap('n', '<leader>bb', 'Switch to buffer by number (5<leader>bb or prompts)', 'Buffer Navigation')
keybind_docs.document_keymap('n', '<leader>bd', 'Delete current buffer (go to previous)', 'Buffer Navigation')
keybind_docs.document_keymap('n', '<leader>bD', 'Close all buffers (with confirmation)', 'Buffer Navigation')
keybind_docs.document_keymap('n', '<leader>e', 'Show diagnostic message for current line', 'Diagnostics')
keybind_docs.document_keymap('n', '[d', 'Previous diagnostic', 'Diagnostics')
keybind_docs.document_keymap('n', ']d', 'Next diagnostic', 'Diagnostics')

-- Comment.nvim keybindings (provided by Comment.nvim plugin)
keybind_docs.document_keymap('n', 'gcc', 'Toggle current line (linewise comment)', 'Commenting')
keybind_docs.document_keymap('n', 'gbc', 'Toggle current line (blockwise comment)', 'Commenting')
keybind_docs.document_keymap('n', 'gc{motion}', 'Toggle region (linewise comment)', 'Commenting')
keybind_docs.document_keymap('n', 'gb{motion}', 'Toggle region (blockwise comment)', 'Commenting')
keybind_docs.document_keymap('v', 'gc', 'Toggle region (linewise comment)', 'Commenting')
keybind_docs.document_keymap('v', 'gb', 'Toggle region (blockwise comment)', 'Commenting')
keybind_docs.document_keymap('n', 'gco', 'Insert comment below and enter insert mode', 'Commenting')
keybind_docs.document_keymap('n', 'gcO', 'Insert comment above and enter insert mode', 'Commenting')
keybind_docs.document_keymap('n', 'gcA', 'Insert comment at line end and enter insert mode', 'Commenting')