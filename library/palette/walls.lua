local factoring = require("tech.factoring")
local on_solids = require("library.palette.on_solids")


local walls, module_mt, static = Module("library.palette.walls")

factoring.from_atlas(walls, "assets/sprites/atlases/walls.png", {
  layer = "solids",
  view = "scene",
}, {
  "steel", "steel", "steel", "steel", "steel", "steel", false, false,
  false, false, "steel", "steel", "steel", "steel", false, false,
  "megadoor1", "megadoor2", "megadoor3", false, "steel", "steel", false, false,
  false, false, false, false, "steel", "steel",
})

for i = 1, 3 do
  factoring.extend(walls, "megadoor" .. i, {
    open = function(self)
      State:remove(self)
      State:add(on_solids["megadoor%s_open" % i](), {position = self.position})
    end,
  })
end

return walls
