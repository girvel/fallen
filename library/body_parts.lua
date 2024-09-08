local animated = require("tech.animated")


local body_parts, module_mt, static = Module("library.body_parts")

body_parts.furry_head = function()
  return Table.extend(
    animated("assets/sprites/animations/furry_head", "atlas"),
    {
      direction = "right",
      codename = "furry_head",
      slot = "head",
    }
  )
end

return body_parts
