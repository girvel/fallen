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

module.get_melee_modifier = function(entity, slot)
  if -Query(entity).inventory[slot].tags.finesse then
    return module.get_modifier(math.max(entity.abilities.strength, entity.abilities.dexterity))
  end
  return module.get_modifier(entity.abilities.strength)
end

module.experience_for_level = {
  [0] = -1,
  0, 300, 900, 2700, 6500,
}

return module
