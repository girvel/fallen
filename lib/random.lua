local random = {}

--- Returns true with given chance
--- @param chance number
--- @return boolean
random.chance = function(chance)
	return math.random() < chance
end

--- Chooses random element from the list
--- @generic T
--- @param list T[]
--- @return T
random.choice = function(list)
  assert(#list > 0, "Can not random.choice with empty list")
	return list[math.ceil(math.random(#list))]
end

return random
