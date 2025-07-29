-- Keybinding documentation system
local M = {}

local keybind_docs = {}

function M.document_keymap(mode, key, desc, category)
  if not keybind_docs[category] then keybind_docs[category] = {} end
  table.insert(keybind_docs[category], {mode = mode, key = key, desc = desc})
end

function M.map_and_doc(mode, key, action, opts, category)
  opts = opts or {}
  vim.keymap.set(mode, key, action, opts)
  if opts.desc then
    M.document_keymap(mode, key, opts.desc, category or "General")
  end
end

function M.generate_keybinding_docs()
  -- Get current leader key
  local leader = vim.g.mapleader or "\\"
  if leader == " " then
    leader = "space"
  elseif leader == "\\" then
    leader = "backslash (\\)"
  end
  
  local doc_content = {
    "*keybindings.txt*\tCustom Neovim Keybindings",
    "",
    "==============================================================================",
    "CONTENTS\t\t\t\t\t*keybindings-contents*",
    ""
  }
  
  local sections = {}
  local section_count = 1
  
  for category, bindings in pairs(keybind_docs) do
    local section_name = category:lower():gsub("%s+", "-")
    table.insert(sections, string.format("%d. %s\t\t\t|keybindings-%s|", section_count, category, section_name))
    section_count = section_count + 1
  end
  
  for _, section in ipairs(sections) do
    table.insert(doc_content, section)
  end
  
  table.insert(doc_content, "")
  
  for category, bindings in pairs(keybind_docs) do
    local section_name = category:lower():gsub("%s+", "-")
    table.insert(doc_content, "==============================================================================")
    table.insert(doc_content, string.format("%s\t\t\t\t*keybindings-%s*", category:upper(), section_name))
    table.insert(doc_content, "")
    
    if category:find("LSP") or category:find("Git Signs") then
      table.insert(doc_content, string.format("Available when %s is attached to buffer:", category:lower()))
      table.insert(doc_content, "")
    end
    
    for _, binding in ipairs(bindings) do
      local key_display = binding.key:gsub("<leader>", "<leader>"):gsub("<", "<"):gsub(">", ">")
      table.insert(doc_content, string.format("%-20s\t%s", key_display, binding.desc))
    end
    table.insert(doc_content, "")
  end
  
  table.insert(doc_content, "==============================================================================")
  table.insert(doc_content, "NOTES\t\t\t\t\t*keybindings-notes*")
  table.insert(doc_content, "")
  table.insert(doc_content, string.format("- <leader> is currently mapped to the %s key", leader))
  table.insert(doc_content, "- Buffer-specific keybindings are only available in buffers where the")
  table.insert(doc_content, "  respective plugin is active")
  table.insert(doc_content, "- Text objects can be used with operators (e.g., `daf` to delete a function,")
  table.insert(doc_content, "  `vif` to select inside a function)")
  table.insert(doc_content, "")
  table.insert(doc_content, " vim:tw=78:ts=8:noet:ft=help:norl:")
  
  local doc_path = vim.fn.stdpath("config") .. "/doc/keybindings.txt"
  local file = io.open(doc_path, "w")
  if file then
    file:write(table.concat(doc_content, "\n"))
    file:close()
    print("Generated keybinding documentation at " .. doc_path)
  else
    print("Error: Could not write to " .. doc_path)
  end
end

return M