local module = {}

module.extend = function(base, extension)
  for k, v in pairs(extension) do
    base[k] = v
  end
  return base
end

module.concat = function(base, extension)
  for _, v in ipairs(extension) do
    table.insert(base, v)
  end
  return base
end

module._periods = {}

module.period = function(identifier, period, dt)
  local result = false
  local value = module._periods[identifier] or 0
  value = value + dt
  if value > period then
    value = value - period
    result = true
  end
  module._periods[identifier] = value
  return result
end

return module
