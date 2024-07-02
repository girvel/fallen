local animated = require("tech.animated")


local module = {}

module.rapier = animated.load_pack("assets/sprites/rapier", {
  idle_right = {
    Vector({4, 11}),
  },
  idle_left = {
    Vector({11, 11}),
  },
})

module.player_character = animated.load_pack("assets/sprites/player_character", {
  idle_right = {
    Vector({3, 12}),
  },
  idle_left = {
    Vector({11, 12}),
  },
})

return module
