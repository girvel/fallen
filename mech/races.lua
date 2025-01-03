local class = require("mech.class")
local feats = require("mech.feats")
local abilities = require("mech.abilities")


local races, _, static = Module("mech.races")

races.half_orc = static {
  codename = "half_orc",
  skin_color = Colors.from_hex("60b37e"),
  movement_speed = 6,
  progression_table = {},
}

races.half_elf = static {
  codename = "half_elf",
  skin_color = Colors.from_hex("c9c7ec"),
  movement_speed = 6,
  progression_table = {},
}

races.halfling = static {
  codename = "halfling",
  skin_color = Colors.from_hex("d2d2ba"),
  movement_speed = 5,
  progression_table = {},
}

races.dwarf = static {
  codename = "dwarf",
  skin_color = Colors.from_hex("dd8a5b"),
  movement_speed = 5,
  progression_table = {},
}

races.human = static {
  name = "Человек",
  codename = "human",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  progression_table = {
    [1] = {
      class.universal_ability_bonus(1),
      class.skill_proficiency(abilities.skills),
      class.skill_proficiency(abilities.skills),
    },
  },
}

races.variant_human_1 = static {
  name = "Человек (вариант) +1/+1",
  codename = "variant_human_1",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {1, 1},
  progression_table = {
    [1] = {
      class.ability_bonus(1),
      class.ability_bonus(1),
      class.skill_proficiency(abilities.skills),
      class.skill_proficiency(abilities.skills),
      feats.perk,
    },
  },
}

races.variant_human_2 = static {
  name = "Человек (вариант) +2",
  codename = "variant_human_2",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {2},
  progression_table = {
    [1] = {
      class.ability_bonus(2),
      class.skill_proficiency(abilities.skills),
      class.skill_proficiency(abilities.skills),
      class.skill_proficiency(abilities.skills),
      feats.perk,
    },
  },
}

races.phantom = static {
  codename = "phantom",
  skin_color = Colors.from_hex("c9c7ec"),
  movement_speed = 6,
  progression_table = {},
}

races.furry = static {
  codename = "furry",
  skin_color = Colors.from_hex("3f5d92"),
  movement_speed = 6,
  progression_table = {},
}

races.bat = static {
  codename = "bat",
  movement_speed = 8,
}

return races
