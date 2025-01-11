local uv = vim.loop
local api = vim.api
local fn = vim.fn

local M = {}

function M.setup()
  local root = fn.getcwd()
  local file_path = root .. "/willtmp/project.lua"

  -- Check if file exists
  local stat = uv.fs_stat(file_path)
  if not stat then return end

  -- Initial load
  dofile(file_path)

  -- Set up file watcher
  local watcher = uv.new_fs_event()
  local function on_change(err, _filename, _events)
    if err then return end

    -- Schedule file reload in main loop
    vim.schedule(function()
      dofile(file_path)
      print "Reloaded project.lua"
    end)
  end

  -- Start watching
  if watcher then watcher:start(file_path, {}, vim.schedule_wrap(on_change)) end

  -- Clean up on exit
  api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if watcher then watcher:stop() end
    end,
  })
end

return M
