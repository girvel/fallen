local sprite = require("tech.sprite")
local sound = require("tech.sound")
local factoring = require("tech.factoring")


local decorations, module_mt, static = Module("library.decorations")

local decorations_atlas = "assets/sprites/atlases/decorations.png"
Tablex.extend(decorations, factoring.from_atlas(decorations_atlas, {
  view = "scene",
  layer = "solids",
  transparent_flag = true,
}, {
  "device_panel", "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "upper_bed", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
  "lower_bed", "chamber_pot", "bucket", false, "bed", "sink",
}))

factoring.extend(decorations, "device_panel", {
  hp = 1,
  hardness = 15,
  sounds = {
    hit = sound.multiple("assets/sounds/glass_breaking", 0.5),
  },
  on_remove = function(self)
    State:add(Tablex.extend(decorations.device_panel_broken(), {position = self.position}))
  end,
})

return decorations
