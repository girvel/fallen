local random = {}

random.chance = function(chance)
	return math.random() < chance
end

random.choice = function(list)
  assert(#list > 0, "Can not random.choice with empty list")
	return list[math.ceil(math.random(#list))]
end

return random
