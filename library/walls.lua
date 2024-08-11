local sprite = require("tech.sprite")


local walls, module_mt, static = Module("library.walls")

for i, name in ipairs({
  "steel", "steel_variant", "steel_with_mirror"
}) do
  if not name then return end
  walls[name] = function()
    return {
      sprite = sprite.from_atlas("assets/sprites/atlases/walls.png", i),
      layer = "solids",
      view = "scene",
      codename = name,
    }
  end
end

return walls
