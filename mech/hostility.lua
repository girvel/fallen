local hostility = Module("mech.hostility")

--- @param first entity
--- @param second entity
--- @return boolean
hostility.are_hostile = function(first, second)
  return first.faction and second.faction and (
    State.factions[first.faction].aggressive_towards[second.faction]
    or State.factions[second.faction].aggressive_towards[first.faction]
  ) or false
end

hostility.make_hostile = function(faction)
  State.factions[faction].aggressive_towards.player = true
end

hostility.make_friendly = function(faction)
  State.factions[faction].aggressive_towards.player = false
end

return hostility
