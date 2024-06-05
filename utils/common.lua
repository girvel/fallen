local module = {}

module.extend = function(base, extension, ...)
  if extension == nil then return base end

  for k, v in pairs(extension) do
    base[k] = v
  end
  return module.extend(base, ...)
end

module.concat = function(base, extension)
  for _, v in ipairs(extension) do
    table.insert(base, v)
  end
  return base
end

module.deep_copy = function(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[module.deep_copy(k, seen)] = module.deep_copy(v, seen)
    end
    setmetatable(no, module.deep_copy(getmetatable(o), seen))
  else
    no = o
  end
  return no
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

module.hex_color = function(str)
  return Fun.range(3)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

module.median = function(...)
  local t = {...}
  table.sort(t)
  return t[math.ceil(#t / 2)]
end

return module
