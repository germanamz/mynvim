local M = {}

---Return `path` relative to `base`. Falls back to absolute if not inside `base`.
---@param path string absolute file path
---@param base string absolute directory path (reference)
---@return string
function M.relative(path, base)
  base = base:gsub('[\\/]+$', '')          -- trim trailing slash
  local norm = function(p) return p:gsub('[\\/]+', '/') end
  path, base = norm(path), norm(base)
  if path:sub(1, #base + 1) == base .. '/' then
    return path:sub(#base + 2)             -- cut "base/"
  end
  return path                              -- outside base → keep absolute
end

return M

