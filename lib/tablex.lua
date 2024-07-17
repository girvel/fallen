local module = {}

module.extend = function(base, extension, ...)
  if extension == nil then return base end
  for k, v in pairs(extension) do
    base[k] = v
  end
  return module.extend(base, ...)
end

module.concat = function(base, extension, ...)
  if extension == nil then return base end
  for _, v in ipairs(extension) do
    table.insert(base, v)
  end
  return module.concat(base, ...)
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

module.remove = function(t, item)
  return Fun.iter(pairs(t))
    :filter(function(k, v) return v ~= item end)
    :tomap()
end

return module
