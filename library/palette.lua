local library = require("library")


return {
  tiles = {
    _ = library.planks,
    [","] = library.grass,
    ["c"] = library.scripture_straight,
  },
  solids = {
    ["#"] = library.wall,
    ["%"] = library.crooked_wall,
    S = library.smooth_wall,
    ["@"] = library.player,
    b = library.bat,
  },
}
