-- Buffer utility functions
local M = {}

-- Check if buffer should be considered for display (matches filtering logic)
function M.is_valid_buffer(buf)
  if not vim.api.nvim_buf_is_loaded(buf) or not vim.api.nvim_buf_get_option(buf, 'buflisted') then
    return false
  end
  
  local bufname = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
  local filename = vim.fn.fnamemodify(bufname, ':t')

  return buftype == ''
    and bufname ~= ''
    and not bufname:match('NvimTree')
    and filename ~= ''
    and filename ~= '[No Name]'
end

-- Get list of valid buffers (excluding special buffers like nvim-tree, terminals, etc.)
function M.get_valid_buffers()
  local buf_list = vim.api.nvim_list_bufs()
  local valid_bufs = {}
  
  for _, buf in ipairs(buf_list) do
    if M.is_valid_buffer(buf) then
      table.insert(valid_bufs, buf)
    end
  end
  
  return valid_bufs
end

-- Smart buffer deletion that navigates to previous buffer
function M.smart_delete()
  local current_buf = vim.api.nvim_get_current_buf()
  local valid_bufs = M.get_valid_buffers()
  local current_index = nil
  
  -- Find current buffer index
  for i, buf in ipairs(valid_bufs) do
    if buf == current_buf then
      current_index = i
      break
    end
  end
  
  -- If we have more than one buffer and found current buffer
  if #valid_bufs > 1 and current_index then
    local target_buf
    -- Go to previous buffer (left), or last if we're at the beginning
    if current_index > 1 then
      target_buf = valid_bufs[current_index - 1]
    else
      target_buf = valid_bufs[#valid_bufs]
    end
    
    -- Switch to target buffer before deleting current
    vim.api.nvim_set_current_buf(target_buf)
  end
  
  -- Delete the original buffer
  vim.cmd("bdelete " .. current_buf)
end

return M