local static = require("library.static")
local player = require("library.player")
local mobs = require("library.mobs")


return {
  tiles = {
    _ = static.planks,
    [","] = static.grass,
    ["c"] = static.scripture_straight,
  },
  solids = {
    ["#"] = static.wall,
    ["%"] = static.crooked_wall,
    S = static.smooth_wall,
    ["@"] = player,
    b = mobs.bat,
    m = mobs.moose_dude,
    e = mobs.exploding_dude,
  },
}
