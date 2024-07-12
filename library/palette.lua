local static = require("library.static")
local player = require("library.player")
local mobs = require("library.mobs")
local weapons = require("library.weapons")


return {
  factories = {
    -- TODO do we really need layers in palette? Aren't they already set?
    tiles = {
      _ = static.planks,
      ["c"] = static.scripture,
      s = static.sand,
      w = static.walkway,
    },
    solids = {
      ["#"] = static.wall,
      ["%"] = static.crooked_wall,
      S = static.smooth_wall,
      V = static.wall_with_vines,
      W = static.steel_wall,

      [","] = static.bushes,

      [">"] = static.pipe,
      ["B"] = static.braced_pipe,
      ["\\"] = static.pipe_left_back,
      ["}"] = static.pipe_left_down,
      ["F"] = static.pipe_forward_down,

      M = static.mannequin,
      D = static.door,
      l = static.lever,

      ["@"] = player,
    },
    items = {
      g = weapons.greatsword,
      r = weapons.rapier,
    },
  },
  transparents = Common.set("Ml@gr>B\\}"),
}
