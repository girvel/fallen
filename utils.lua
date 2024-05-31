local module = {}

module.chance = function(chance)
	return math.random() < chance
end

module.choice = function(list)
	return list[math.ceil(math.random() * #list)]
end

module.extend = function(base, extension)
  for k, v in pairs(extension) do
    base[k] = v
  end
  return base
end

return module
