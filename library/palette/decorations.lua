local sprite = require("tech.sprite")
local sound = require("tech.sound")
local factoring = require("tech.factoring")
local level = require("state.level")
local shaders = require("tech.shaders")


local decorations, module_mt, static = Module("library.palette.decorations")

local decorations_atlas = "assets/sprites/atlases/decorations.png"
factoring.from_atlas(decorations, decorations_atlas, {
  view = "scene",
  layer = "solids",
  transparent_flag = true,
}, {
  "device_panel", "device_panel_broken", "furnace", "table", "locker", "locker_damaged", "cabinet", "cabinet_damaged",
  "lower_bunk", "crate", "crate_open", "chest", "chest_open", "table_left", "table_hor", "table_right",
  false, "chamber_pot", "bucket", false, "countertop", "oven", "kitchen_sink", "countertop",
  "table_up", "mirage_block", "stool", "sofa", "countertop_left", "bed", "sink", "countertop",
  "table_ver", "transparent_wall", "low_wall", "scratched_table", "countertop", "countertop", "empty_bed", "countertop",
  "table_down", "cage", "device_panel_v1", "device_panel_v2", "countertop", "cabinet", "cabinet", "countertop",
  "cabinet", "cabinet", "cabinet", "cabinet", "sofa", "sofa", "stand", false,
  "low_wall", "low_wall", "low_wall", "low_wall", "coal", "coal", "coal", "coal",
  "low_wall", "low_wall", "low_wall", "low_wall", false, false, false, false,
  false, false, "low_wall", "low_wall", false, false, false, false,
  false, false, "low_wall", "low_wall", false, false, false, false,
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

factoring.extend(decorations, "bucket", {
  shader = shaders.reflective,
  reflection_vector = Vector.left,
})

factoring.extend(decorations, "device_panel", {
  shader = shaders.reflective,
  reflection_vector = Vector.down,
})

factoring.extend(decorations, "device_panel_v2", {
  shader = shaders.reflective,
  reflection_vector = Vector.down,
})

local elevations = {"upper", "lower"}

--- @param entity {animate: function, animation_set_paused: function, perspective_flag: boolean?}
--- @param bed_position vector
--- @param bed_elevation "upper" | "lower"
decorations.lie = function(entity, bed_position, bed_elevation)
  assert(Table.contains(elevations, bed_elevation))

  level.change_layer(entity, "on_solids2")
  level.move(entity, bed_position)
  entity:animate("lying_" .. bed_elevation)
  entity:animation_set_paused(true)
  entity.perspective_flag = true
end

return decorations
