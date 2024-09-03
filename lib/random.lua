local random = {}

random.chance = function(chance)
	return math.random() < chance
end

random.choice = function(list)
	return list[math.ceil(math.random(#list))]
end

return random
