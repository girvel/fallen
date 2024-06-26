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
      [","] = static.bushes,
      M = static.mannequin,
      D = static.door,
      l = static.lever,
      k = static.kid,
      t = static.teacher,

      ["@"] = player,
      b = mobs.bat,
      m = mobs.moose_dude,
      e = mobs.exploding_dude,
      f = mobs.first,
    },
    sfx = {
      O = static.key_point,
    },
    items = {
      d = weapons.shortsword,
    },
  },
  transparents = {
    M = true,
    l = true,
    ["@"] = true,
    b = true,
    m = true,
    e = true,
    f = true,
    O = true,
    d = true,
  },
}
