local common = require("lib.Common")
local tablex = require("lib.tablex")


local module_mt = {}
local static = setmetatable({}, module_mt)

static._module = nil

static.module = function(path)
  assert(type(path) == "string", "Expected module name to be a string")
  static._module = path
end

local walk_table
walk_table = function(t, path, module)
  for k, v in pairs(t) do
    if type(v) == "table" then
      local mt = getmetatable(v)
      if mt and mt.__module == module then
        static(v)
      end
      walk_table(v, tablex.concat({}, path, {k}), module)
    end
  end
end

module_mt.__call = function(_, a, b)
  local path, value
  if b then
    path = type(a) == "string" and a / "." or a
    value = b
  else
    path = {}
    value = a
  end

  assert(type(value) == "table", "Only table values are supported")

  local mt = getmetatable(value)
  if not mt then
    mt = {}
    setmetatable(value, mt)
  end

  mt.__module = static._module
  local module = static._module
  mt.__serialize = function()
    return function() return Common.get_by_path(require(module), path) end
  end

  walk_table(value, path)

  return value
end

return static
