local module, _, static = Module("mech.races")

module.half_orc = {
  codename = "half_orc",
  skin_color = Colors.from_hex("60b37e"),
  movement_speed = 6,
}

module.half_elf = {
  codename = "half_elf",
  skin_color = Colors.from_hex("c9c7ec"),
  movement_speed = 6,
}

module.halfling = {
  codename = "halfling",
  skin_color = Colors.from_hex("d2d2ba"),
  movement_speed = 5,
}

module.dwarf = {
  codename = "dwarf",
  skin_color = Colors.from_hex("dd8a5b"),
  movement_speed = 5,
}

module.human = {
  codename = "human",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {1, 1, 1, 1, 1, 1},
}

module.variant_human_1 = {
  codename = "variant_human_1",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {1, 1},
  feat_flag = true,
}

module.variant_human_2 = {
  codename = "variant_human_2",
  skin_color = Colors.from_hex("8ed3dc"),
  movement_speed = 6,
  bonuses = {2},
  feat_flag = true,
}

module.phantom = {
  codename = "phantom",
  skin_color = Colors.from_hex("c9c7ec"),
  movement_speed = 6,
}

return module
