local static = require("library.static")
local player = require("library.player")
local mobs = require("library.mobs")


return {
  factories = {
    tiles = {
      _ = static.planks,
      ["c"] = static.scripture,
    },
    solids = {
      ["#"] = static.wall,
      ["%"] = static.crooked_wall,
      S = static.smooth_wall,
      [","] = static.bushes,
      M = static.mannequin,
      D = static.door,
      l = static.lever,
      ["@"] = player,
      b = mobs.bat,
      m = mobs.moose_dude,
      e = mobs.exploding_dude,
    },
  },
  transparents = {
    M = true,
    l = true,
    ["@"] = true,
    b = true,
    m = true,
    e = true,
  },
}
