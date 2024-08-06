local common = require("lib.Common")


local module_mt = {}
local const = setmetatable({}, module_mt)

const._module = nil

const.module = function(path)
  assert(type(path) == "string", "Expected module name to be a string")
  const._module = path
end

module_mt.__call = function(_, a, b)
  local path, value
  if b then
    path = a / "."
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

  local module = const._module
  mt.__serialize = function()
    return function() return Common.get_by_path(require(module), path) end
  end

  return value
end

return const
