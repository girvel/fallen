local module = {}

module.rogue = {
  hp_die = 8,
}

module.charming_leader = {
  hp_die = 10,
  save_proficiencies = Common.set({"strength", "constitution", "dexterity"}),
}

module.paladin = {
  hp_die = 10,
}

return module
