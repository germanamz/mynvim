-- Theme and colorscheme configuration
local M = {}

function M.setup()
  -- Set colorscheme
  vim.cmd.colorscheme("github_light")

  -- Fix whitespace colors for github theme
  vim.api.nvim_set_hl(0, "Whitespace", { fg = "#d1d9e0" })
  vim.api.nvim_set_hl(0, "NonText", { fg = "#d1d9e0" })
end

return M