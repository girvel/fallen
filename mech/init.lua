local module, _, static = Module("mech")

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

module.abilities = function(str, dex, con, int, wis, cha)
  return {
    strength = str,
    dexterity = dex,
    constitution = con,
    intelligence = int,
    wisdom = wis,
    charisma = cha,
  }
end

module.abilities_list = {
  "strength", "dexterity", "constitution",
  "intelligence", "wisdom", "charisma",
}

module.are_hostile = function(first, second)
  return first.faction and second.faction and (
    State.factions[first.faction].aggressive_towards[second.faction]
    or State.factions[second.faction].aggressive_towards[first.faction]
  )
end

module.get_melee_modifier = function(entity, slot)
  if -Query(entity).inventory[slot].tags.finesse then
    return module.get_modifier(math.max(entity.abilities.strength, entity.abilities.dexterity))
  end
  return module.get_modifier(entity.abilities.strength)
end

-- TODO module hostility
module.make_hostile = function(faction)
  State.factions[faction].aggressive_towards.player = true
end

module.make_friendly = function(faction)
  State.factions[faction].aggressive_towards.player = false
end

return module
