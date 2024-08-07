local module, _, static = Module("utils.random")

module.chance = function(chance)
	return math.random() < chance
end

module.choice = function(list)
	return list[math.ceil(math.random(#list))]
end

module.d = function(sides)
  return math.random(sides)
end

return module
