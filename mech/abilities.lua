local sound = require("tech.sound")


local abilities, module_mt, static = Module("mech.abilities")

abilities.list = {
  "str", "dex", "con",
  "int", "wis", "cha",
}

abilities.skills = {
  "sleight_of_hand",
  "arcana",
  "history",
  "investigation",
  "nature",
  "religion",
  "insight",
  "medicine",
  "perception",
  "intimidation",
  "persuasion",
}

abilities.skill_bases = {
  sleight_of_hand = "dex",
  arcana = "int",
  history = "int",
  investigation = "int",
  nature = "int",
  religion = "int",
  insight = "wis",
  medicine = "wis",
  perception = "wis",
  intimidation = "cha",
  persuasion = "cha",
}

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

abilities.get_modifier = function(abilities_score)
  if not abilities_score then
    error("abilities_score is nil", 2)
  end
  return math.floor((abilities_score - 10) / 2)
end

abilities.get_melee_modifier = function(entity, slot)
  if -Query(entity).inventory[slot].tags.finesse then
    return abilities.get_modifier(math.max(entity.abilities.str, entity.abilities.dex))
  end
  return abilities.get_modifier(entity.abilities.str)
end

local ability_check_sound = {
  success = sound.multiple("assets/sounds/coin_toss", 1),
  failure = sound.multiple("assets/sounds/check_failed", 0.3),
}

abilities.check = function(entity, skill_or_abilities, dc)
  local roll = entity.abilities[skill_or_abilities]
    and D(20) + abilities.get_modifier(entity.abilities[skill_or_abilities])
    or entity.skill_throws[skill_or_abilities]

  if not roll then
    error("No abilities or skill %s" % skill_or_abilities, 2)
  end

  local result = roll:roll()
  Log.info("%s rolls check %s: %s against %s" % {
    Entity.name(entity), skill_or_abilities, result, dc
  })

  local success = result >= dc
  sound.play(
    ability_check_sound[success and "success" or "failure"],
    entity.position,
    "small"
  )
  return success
end

abilities.saving_throw = function(entity, ability, dc)
  local save = entity:get_saving_throw(ability):roll()
  Log.info("%s rolls %s save %s against %s" % {
    Entity.name(entity), ability, save, dc
  })

  local success = save >= dc
  sound.play(
    ability_check_sound[success and "success" or "failure"],
    entity.position,
    "small"
  )
  return success
end

abilities.initiative_roll = function(entity)
  local result = D(20) + abilities.get_modifier(entity.abilities.dex) + (entity.initiative_bonus or 0)
  Log.debug("%s rolls initiative" % {Entity.name(entity)})
  return result
end

return abilities
