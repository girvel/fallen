local animated = require("tech.animated")


local module = {}

module.rapier = animated.load_pack("assets/sprites/rapier", {
  idle_right = {
    Vector({4, 11}),
  },
  idle_left = {
    Vector({11, 11}),
  },
  idle_down = {
    Vector({7, 6}),
  },
  idle_up = {
    Vector({7, 13}),
  },
})

module.greatsword = animated.load_pack("assets/sprites/greatsword", {
  idle_right = {
    Vector({2, 11}),
  },
  idle_left = {
    Vector({11, 11}),
  },
  idle_down = {
    Vector({7, 6}),
  },
  idle_up = {
    Vector({7, 13}),
  },
})

module.player_character = animated.load_pack("assets/sprites/player_character", {
  idle_right = {
    Vector({3, 12}),
  },
  idle_left = {
    Vector({11, 12}),
  },
  idle_down = {
    Vector({3, 12}),
  },
  idle_up = {
    Vector({11, 12}),
  },
  attack_right = {
    Vector({2, 12}),
    Vector({14, 11}),
  },
  attack_left = {
    Vector({12, 12}),
    Vector({0, 11}),
  },
  attack_down = {
    Vector({3, 11}),
    Vector({3, 15}),
  },
  attack_up = {
    Vector({11, 13}),
    Vector({11, 8}),
  },
  move_right = {
    Vector({3, 12}),
    Vector({3, 12}),
    Vector({3, 12}),
  },
  move_left = {
    Vector({11, 12}),
    Vector({11, 12}),
    Vector({11, 12}),
  },
  move_down = {
    Vector({3, 12}),
    Vector({3, 12}),
    Vector({3, 12}),
  },
  move_up = {
    Vector({11, 12}),
    Vector({11, 12}),
    Vector({11, 12}),
  },
})

return module
