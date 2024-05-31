local module = {}

module.chance = function(chance)
	return math.random() < chance
end

module.choice = function(list)
	return list[math.ceil(math.random() * #list)]
end

module.d = function(sides)
  return math.ceil(math.random() * sides)
end

return module
