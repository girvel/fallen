local animated = require("tech.animated")


local animation_packs, _, static = Module("library.animation_packs")

animation_packs.rapier = animated.load_pack("assets/sprites/animations/rapier")
animation_packs.dagger = animated.load_atlas_pack("assets/sprites/animations/dagger")
animation_packs.knife = animated.load_atlas_pack("assets/sprites/animations/knife")
animation_packs.machete = animated.load_atlas_pack("assets/sprites/animations/machete")
animation_packs.mace = animated.load_atlas_pack("assets/sprites/animations/mace")
animation_packs.shield = animated.load_atlas_pack("assets/sprites/animations/shield")
animation_packs.greatsword = animated.load_pack("assets/sprites/animations/greatsword")
animation_packs.pole = animated.load_atlas_pack("assets/sprites/animations/pole")

animation_packs.gas_key = animated.load_atlas_pack("assets/sprites/animations/gas_key")

animation_packs.yellow_gloves = animated.load_pack("assets/sprites/animations/yellow_gloves")
animation_packs.skeleton = animated.load_atlas_pack("assets/sprites/animations/skeleton")

return animation_packs
