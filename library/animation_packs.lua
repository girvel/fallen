local animated = require("tech.animated")
local humanoid_anchors = require("core.humanoid.anchors")


local module = {}

local small_weapon_anchors = {
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
}

module.rapier = animated.load_pack("assets/sprites/rapier", small_weapon_anchors)
module.dagger = animated.load_pack("assets/sprites/dagger", small_weapon_anchors)

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

module.gas_key = animated.load_pack("assets/sprites/gas_key", {
  idle_right = {
    Vector({6, 10}),
  },
  idle_left = {
    Vector({9, 10}),
  },
  idle_down = {
    Vector({8, 7}),
  },
  idle_up = {
    Vector({8, 11}),
  },
})

module.yellow_glove = animated.load_pack("assets/sprites/yellow_glove")

module.skeleton = animated.load_pack("assets/sprites/skeleton", humanoid_anchors)

return module
