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
    Vector({13, 11}),
  },
  idle_down = {
    Vector({7, 5}),
  },
  idle_up = {
    Vector({7, 13}),
  },
})

return module
