-- Custom tabline configuration
local M = {}

-- Helper function to get unique buffer names
local function get_buffer_display_names(buffers)
  local buffer_names = {}
  local name_counts = {}
  
  -- First pass: collect all filenames and count duplicates
  for _, buf_info in ipairs(buffers) do
    local filename = buf_info.filename
    name_counts[filename] = (name_counts[filename] or 0) + 1
  end
  
  -- Second pass: create unique display names
  local path_counts = {}
  for _, buf_info in ipairs(buffers) do
    local filename = buf_info.filename
    local bufname = buf_info.bufname
    local buf = buf_info.buf
    
    if name_counts[filename] > 1 then
      -- Need to differentiate - use parent directory
      local parent_dir = vim.fn.fnamemodify(bufname, ':h:t')
      if parent_dir == '.' or parent_dir == '' then
        parent_dir = vim.fn.fnamemodify(bufname, ':h')
        if parent_dir:match('^/') then
          parent_dir = vim.fn.fnamemodify(parent_dir, ':t')
        end
      end
      
      local display_name = parent_dir .. '/' .. filename
      
      -- If parent dir names also conflict, use more of the path
      if path_counts[display_name] then
        local full_path = vim.fn.fnamemodify(bufname, ':~:.')
        local path_parts = vim.split(full_path, '/')
        if #path_parts > 2 then
          display_name = table.concat({path_parts[#path_parts-1], filename}, '/')
        else
          display_name = full_path
        end
      end
      
      path_counts[display_name] = true
      buffer_names[buf] = display_name
    else
      buffer_names[buf] = filename
    end
  end
  
  return buffer_names
end

-- Custom tabline function to show buffers as tabs
function _G.custom_tabline()
  local tabline = ''
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = {}
  
  -- Collect buffer information
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      
      -- Skip special buffers
      if buftype == '' and bufname ~= '' and not bufname:match('NvimTree') then
        local filename = vim.fn.fnamemodify(bufname, ':t')
        if filename == '' then filename = '[No Name]' end
        
        table.insert(buffers, {
          buf = buf,
          bufname = bufname,
          filename = filename
        })
      end
    end
  end
  
  -- Get unique display names
  local display_names = get_buffer_display_names(buffers)
  
  -- Build tabline
  for _, buf_info in ipairs(buffers) do
    local buf = buf_info.buf
    local display_name = display_names[buf]
    
    -- Add modified indicator
    local modified = vim.api.nvim_buf_get_option(buf, 'modified') and '*' or ''
    
    -- Highlight current buffer
    local highlight = (buf == current_buf) and '%#TabLineSel#' or '%#TabLine#'
    
    tabline = tabline .. highlight .. ' ' .. buf .. ':' .. display_name .. modified .. ' %#TabLine#|'
  end
  
  return tabline .. '%#TabLineFill#'
end

function M.setup()
  vim.opt.tabline = '%!v:lua.custom_tabline()'
end

return M