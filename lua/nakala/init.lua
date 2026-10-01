local M = {}

local NakalaCore = require("nakala.core")

function M.setup(opts)
  opts = opts or {}
  NakalaCore.setup({
    enabled = opts.keep_paste_register ~= false,
  })
end

M.toggle = NakalaCore.toggle
M.enable = NakalaCore.enable
M.disable = NakalaCore.disable

return M
