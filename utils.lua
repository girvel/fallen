local module = {}

module.hex_color = function(str)
  return Fun.range(3)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

module.chance = function(chance)
	return math.random() < chance
end

module.choice = function(list)
	return list[math.ceil(math.random() * #list)]
end

return module
