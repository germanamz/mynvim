-- lua/pkgmgr.lua
local M = {}

local util = require("lspconfig.util")
local uv = vim.loop

-- Files that identify the *workspace* root
M.workspace_root_patterns = {
  -- pnpm
  "pnpm-workspace.yaml",
  -- npm
  "package-lock.json",
  "npm-shrinkwrap.json",
  -- Yarn classic & Berry
  "yarn.lock",
  ".pnp.cjs",           -- Yarn Plug'n'Play :contentReference[oaicite:0]{index=0}
  -- Bun
  "bun.lock",
  "bun.lockb",          -- text vs. binary lockfiles :contentReference[oaicite:1]{index=1}
  -- always
  ".git",
}

-- Files that identify an individual *package* root
M.package_root_patterns = {
  "tsconfig.json",
  "tsconfig.base.json",
  "tsconfig.app.json",
  "jsconfig.json",
  "package.json",
}

-- Return the nearest package root for a file
function M.package_root(fname)
  return util.root_pattern(unpack(M.package_root_patterns))(fname)
end

-- Return the pnpm workspace root (or git root as fallback)
function M.workspace_root(fname)
  return util.root_pattern(unpack(M.workspace_root_patterns))(fname)
end

-- Prefer a locally installed executable in the *package* first, then workspace, else fallback.
-- Usage: local exe = M.prefer_local("eslint_d", ctx.filename)  -- gives full path or "eslint_d"
function M.prefer_local(exe, fname)
  fname = fname or vim.api.nvim_buf_get_name(0)
  local pkg = M.package_root(fname)
  local ws  = M.workspace_root(fname)
  local try = nil

  if pkg then
    try = pkg .. "/node_modules/.bin/" .. exe
    if uv.fs_stat(try) then return try end
  end

  if ws and ws ~= pkg then
    try = ws .. "/node_modules/.bin/" .. exe
    if uv.fs_stat(try) then return try end
  end

  return exe
end

-- Optionally ensure the chosen package bin dir is prepended to $PATH for spawned jobs
-- (not strictly required if you use absolute paths from prefer_local, but some plugins rely on PATH)
function M.add_package_bin_to_path(fname)
  fname = fname or vim.api.nvim_buf_get_name(0)
  local pkg = M.package_root(fname) or M.workspace_root(fname)
  if not pkg then return end
  local bin = pkg .. "/node_modules/.bin"
  if uv.fs_stat(bin) and not string.find(vim.env.PATH or "", bin, 1, true) then
    vim.env.PATH = bin .. ":" .. vim.env.PATH
  end
end

return M

