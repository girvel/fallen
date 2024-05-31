local module = {}

module.extend = function(base, extension)
  for k, v in pairs(extension) do
    base[k] = v
  end
  return base
end

return module
