local animated = require("tech.animated")
local humanoid_anchors = require("mech.humanoid.anchors")


local animation_packs, _, static = Module("library.animation_packs")

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

local big_weapon_anchors = {
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
}

animation_packs.rapier = animated.load_pack("assets/sprites/animations/rapier", small_weapon_anchors)
animation_packs.dagger = animated.load_atlas_pack("assets/sprites/animations/dagger", small_weapon_anchors)
animation_packs.knife = animated.load_atlas_pack("assets/sprites/animations/knife", small_weapon_anchors)
animation_packs.machete = animated.load_atlas_pack("assets/sprites/animations/machete", small_weapon_anchors)
animation_packs.greatsword = animated.load_pack("assets/sprites/animations/greatsword", big_weapon_anchors)
animation_packs.pole = animated.load_atlas_pack("assets/sprites/animations/pole", big_weapon_anchors)

animation_packs.gas_key = animated.load_pack("assets/sprites/animations/gas_key", {
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

animation_packs.yellow_gloves = animated.load_pack("assets/sprites/animations/yellow_gloves")
animation_packs.skeleton = animated.load_pack("assets/sprites/animations/skeleton", humanoid_anchors)

return animation_packs
