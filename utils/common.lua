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

return module
