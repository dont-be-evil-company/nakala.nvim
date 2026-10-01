local M = {}

local enabled = false
local saved_mappings = {}

local mappings = {
  {
    mode = "x",
    lhs = "p",
    rhs = "P",
    desc = "Paste without overwriting the replaced text register",
  },
}

local function get_mapping(mode, lhs)
  local mapping = vim.fn.maparg(lhs, mode, false, true)

  if type(mapping) ~= "table" or vim.tbl_isempty(mapping) then
    return nil
  end

  return vim.deepcopy(mapping)
end

local function is_our_mapping(mapping, spec)
  if type(mapping) ~= "table" or vim.tbl_isempty(mapping) then
    return false
  end

  return mapping.desc == spec.desc
end

local function save_mapping(spec)
  saved_mappings[spec.mode .. ":" .. spec.lhs] = get_mapping(spec.mode, spec.lhs)
end

local function restore_mapping(spec)
  local key = spec.mode .. ":" .. spec.lhs
  local previous = saved_mappings[key]

  if previous then
    -- Restore the exact mapping that existed before we replaced it.
    vim.fn.mapset(spec.mode, false, previous)
  end

  saved_mappings[key] = nil
end

local function set_mapping(spec)
  vim.keymap.set(spec.mode, spec.lhs, spec.rhs, {
    noremap = true,
    silent = true,
    desc = spec.desc,
  })
end

function M.enable()
  if enabled then
    return
  end

  enabled = true

  for _, spec in ipairs(mappings) do
    save_mapping(spec)
    set_mapping(spec)
  end
end

function M.disable()
  if not enabled then
    return
  end

  enabled = false

  for _, spec in ipairs(mappings) do
    local current = get_mapping(spec.mode, spec.lhs)

    -- Only remove the mapping if it is still ours.
    --
    -- If another plugin/user changed the mapping after we installed ours,
    -- leave their new mapping alone.
    if is_our_mapping(current, spec) then
      vim.keymap.del(spec.mode, spec.lhs)
      restore_mapping(spec)
    else
      -- Someone replaced our mapping, so don't restore the old one over it.
      saved_mappings[spec.mode .. ":" .. spec.lhs] = nil
    end
  end
end

function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end

  return enabled
end

function M.is_enabled()
  return enabled
end

function M.setup(opts)
  opts = opts or {}

  -- Enabled by default.
  if opts.enabled == false then
    M.disable()
  else
    M.enable()
  end
end

return M
