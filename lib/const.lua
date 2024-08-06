local module_mt = {}
local const = setmetatable({}, module_mt)

const._module = nil

const.module = function(path)
  assert(type(path) == "string", "Expected module name to be a string")
  const._module = path
end

module_mt.__call = function(_, value)
  assert(type(value) == "table", "Only table values are supported")

  local mt = getmetatable(value)
  if not mt then
    mt = {}
    setmetatable(value, mt)
  end

  local module = const._module
  mt.__serialize = function()
    return function() return require(module) end
  end

  return value
end

return const
