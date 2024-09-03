local sprite = require("tech.sprite")
local sound = require("tech.sound")
local factoring = require("tech.factoring")
local level = require("state.level")


local decorations, module_mt, static = Module("library.palette.decorations")

local decorations_atlas = "assets/sprites/atlases/decorations.png"
factoring.from_atlas(decorations, decorations_atlas, {
  view = "scene",
  layer = "solids",
  transparent_flag = true,
}, {
  "device_panel", "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "upper_bed", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
  "lower_bed", "chamber_pot", "bucket", false, "countertop", "oven", "kitchen_sink", "countertop",
  "table_up", "mirage_block", "stool", "sofa", "countertop_left", "bed", "sink", "countertop",
  "table_ver", "window", "steel_wall_transparent", "scratched_table", "countertop", "countertop", "empty_bed", "countertop",
  "table_down", "cage", "device_panel", "device_panel", "countertop", "cabinet", "cabinet", "countertop",
  "cabinet", "cabinet", "cabinet", "cabinet", "sofa", "sofa",
})

factoring.extend(decorations, "mirage_block", {name = "Блок миража"})

factoring.extend(decorations, "device_panel", {
  hp = 1,
  hardness = 15,
  sounds = {
    hit = sound.multiple("assets/sounds/glass_breaking", 0.5),
  },
  on_remove = function(self)
    State:add(decorations.device_panel_broken(), {position = self.position})
  end,
})

for _, name in ipairs({"bed", "upper_bed"}) do
  factoring.extend(decorations, name, {
    lie = function(self, other)
      level.change_layer(other, "on_solids")
      level.move(other, self.position)
      other:animate("lying")
      other:animation_set_paused(true)
    end
  })
end

return decorations
