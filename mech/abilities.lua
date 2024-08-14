local random = require("utils.random")
local sound = require("tech.sound")


local abilities, module_mt, static = Module("mech.abilities")

abilities.list = {
  "str", "dex", "con",
  "int", "wis", "cha",
}

abilities.skills = {
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

abilities.skill_bases = {
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

local ability_check_sound = sound.multiple("assets/sounds/coin_toss", 1)

abilities.check = function(entity, skill_or_abilities, dc)
  State.audio:play(entity, random.choice(ability_check_sound):clone(), "small")
  local roll = entity.abilities[skill_or_abilities]
    and D(20) + abilities.get_modifier(entity.abilities[skill_or_abilities])
    or entity.skill_throws[skill_or_abilities]

  if not roll then
    error("No abilities or skill %s" % skill_or_abilities, 2)
  end

  local result = roll:roll()
  Log.info("%s rolls check %s: %s against %s" % {
    Common.get_name(entity), skill_or_abilities, result, dc
  })

  return result >= dc
end

abilities.saving_throw = function(entity, ability, dc)
  State.audio:play(entity, random.choice(ability_check_sound):clone(), "small")
  local save = entity.saving_throws[ability]:roll()
  Log.info("%s rolls %s save %s against %s" % {
    Common.get_name(entity), ability, save, dc
  })
  return save >= dc
end

abilities.initiative_roll = function(entity)
  return D(20) + abilities.get_modifier(entity.abilities.dex) + (entity.initiative_bonus or 0)
end

return abilities
