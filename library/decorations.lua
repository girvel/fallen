local sprite = require("tech.sprite")
local sound = require("tech.sound")


local decorations, module_mt, static = Module("library.decorations")

local decorations_atlas = "assets/sprites/decorations_atlas.png"

Fun.iter({
  false, "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "upper_bed", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
  "lower_bed", "chamber_pot", "bucket", false, "bed", "sink",
}):enumerate():each(function(i, name)
  if not name then return end
  decorations[name] = function()
    return {
      sprite = sprite.from_atlas(decorations_atlas, i),
      view = "scene",
      layer = "solids",
      codename = name,
      transparent_flag = true,
    }
  end
end)

decorations.device_panel = function()
  return {
    sprite = sprite.from_atlas(decorations_atlas, 1),
    view = "scene",
    layer = "solids",
    codename = "device_panel",
    hp = 1,
    hardness = 15,
    sounds = {
      hit = sound.multiple("assets/sounds/glass_breaking", 0.5),
    },
    on_remove = function(self)
      State:add(Tablex.extend(decorations.device_panel_broken(), {position = self.position}))
    end,
    transparent_flag = true,
  }
end

return decorations
