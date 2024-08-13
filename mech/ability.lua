local ability, module_mt, static = Module("mech.ability")

ability.get_modifier = function(ability_score)
  if not ability_score then
    error("ability_score is nil", 2)
  end
  return math.floor((ability_score - 10) / 2)
end

module_mt.__call = function(_, str, dex, con, int, wis, cha)
  return {
    str = str,
    dex = dex,
    con = con,
    int = int,
    wis = wis,
    cha = cha,
  }
end

ability.list = {
  "str", "dex", "con",
  "int", "wis", "cha",
}

ability.get_melee_modifier = function(entity, slot)
  if -Query(entity).inventory[slot].tags.finesse then
    return ability.get_modifier(math.max(entity.abilities.str, entity.abilities.dex))
  end
  return ability.get_modifier(entity.abilities.str)
end

ability.skills = {
  "sleight_of_hand",
  "stealth",
  "arcana",
  "history",
  "investigation",
  "nature",
  "religion",
  "animal_handling",
  "insight",
  "medicine",
  "perception",
  "deception",
  "intimidation",
  "performance",
  "persuasion",
}

ability.skill_bases = {
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

return ability
