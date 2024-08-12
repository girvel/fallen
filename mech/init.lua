local module, _, static = Module("mech")

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

module.abilities = function(str, dex, con, int, wis, cha)
  return {
    str = str,
    dex = dex,
    con = con,
    int = int,
    wis = wis,
    cha = cha,
  }
end

module.abilities_list = {
  "str", "dex", "con",
  "int", "wis", "cha",
}

module.get_melee_modifier = function(entity, slot)
  if -Query(entity).inventory[slot].tags.finesse then
    return module.get_modifier(math.max(entity.abilities.str, entity.abilities.dex))
  end
  return module.get_modifier(entity.abilities.str)
end

module.experience_for_level = {
  [0] = -1,
  0, 300, 900, 2700, 6500,
}

module.skills = {
  sleight_of_hand = "dex",
  stealth = "dex",
  arcana = "int",
  history = "int",
  investigation = "int",
  nature = "int",
  religion = "int",
  animal_handling = "wis",
  insight = "wis",
  medicine = "wis",
  perception = "wis",
  deception = "cha",
  intimidation = "cha",
  performance = "cha",
  persuasion = "cha",
}

return module
