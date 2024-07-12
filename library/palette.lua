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

      [">"] = static.pipe_horizontal,
      v = static.pipe_vertical,
      ["<"] = static.pipe_horizontal_braced,
      ["^"] = static.pipe_vertical_braced,
      ["\\"] = static.pipe_left_back,
      ["/"] = static.pipe_forward_left,
      F = static.pipe_right_forward,
      B = static.pipe_back_right,
      ["}"] = static.pipe_left_down,
      ["{"] = static.pipe_right_down,

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
  transparents = Common.set("Ml@gr>v<^\\/FB}{"),
}
