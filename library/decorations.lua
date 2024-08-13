local sprite = require("tech.sprite")
local sound = require("tech.sound")
local factoring = require("tech.factoring")
local level = require("state.level")


local decorations, module_mt, static = Module("library.decorations")

local decorations_atlas = "assets/sprites/atlases/decorations.png"
factoring.from_atlas(decorations, decorations_atlas, {
  view = "scene",
  layer = "solids",
  transparent_flag = true,
}, {
  "device_panel", "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "upper_bed", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
  "lower_bed", "chamber_pot", "bucket", "cauldron", "countertop_right_down", "oven", "kitchen_sink", "countertop_left_down",
  "table_up", false, "stool", "sofa", "countertop_left", "bed", "sink", "countertop_right",
  "table_ver", "steel_wall_window", "steel_wall_transparent", "scratched_table", "countertop_left_corner_down", "countertop", "empty_bed", "countertop_right_corner_down",
  "table_down", false, false, false, "countertop_left_corner_up", false, false, "countertop_right_corner_up",
})

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
      level.change_layer(other, "above_solids")
      level.move(other, self.position)
      other:animate("lying")
      other:animation_set_paused(true)
    end
  })
end

return decorations
