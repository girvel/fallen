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
      W = static.steel_wall,
      V = static.steel_wall_variant,

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
      T = static.pipe_T,
      ["+"] = static.pipe_x,
      o = static.pipe_valve,
      L = static.leaking_pipe_left_down,

      p = static.device_panel,
      P = static.device_panel_broken,
      f = static.furnace,

      M = static.mannequin,
      D = static.door,
      l = static.lever,

      ["1"] = mobs[1],
      ["2"] = mobs[2],
      ["3"] = mobs[3],
      ["4"] = mobs[4],
      ["@"] = player,
    },
    items = {
      g = weapons.greatsword,
      r = weapons.rapier,
    },
  },
  transparents = Common.set("Ml@gr>v<^\\/FB}{T+o1234LpP"),
}
