local feats = require("mech.feats")


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
  codename = "human",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {1, 1, 1, 1, 1, 1},
  progression_table = {},
}

races.variant_human_1 = static {
  codename = "variant_human_1",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {1, 1},
  progression_table = {
    [1] = {feats.perk},
  },
}

races.variant_human_2 = static {
  codename = "variant_human_2",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {2},
  progression_table = {
    [1] = {feats.perk},
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

return races
