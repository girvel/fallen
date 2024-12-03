local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")
local item = require("tech.item")
local constants = require("tech.constants")


local module, _, static = Module("library.palette.items")

module.knife = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.knife),
    {
      name = "кухонный нож",
      damage_roll = D(2),
      bonus = 1,
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )
end

module.razor = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/razor", "atlas"),
    {
      name = "опасная бритва",
      damage_roll = D(4),
      bonus = 0,
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )
end

module.dagger = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.dagger),
    {
      name = "кортик",
      damage_roll = D(4),
      bonus = 0,
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )
end

module.machete = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.machete),
    {
      name = "мачете",
      damage_roll = D(6),
      bonus = 0,
      tags = {},
      slot = "hands",
    }
  )
end

module.pole = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.pole),
    {
      name = "двуручный шест",
      damage_roll = D(6),
      bonus = -1,
      tags = {
        heavy = true,
        versatile = true,
      },
      slot = "hands",
    }
  )
end

module.mop = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/mop", "atlas"),
    {
      name = "швабра",
      damage_roll = D(6),
      bonus = 0,
      tags = {
        heavy = true,
        versatile = true,
      },
      slot = "hands",
    }
  )
end

module.mace = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.mace),
    {
      direction = "right",
      name = "булава",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        light = true
      },
      slot = "hands",
    }
  )
end

module.greatsword = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.greatsword),
    {
      direction = "right",
      name = "двуручный меч",
      damage_roll = D(6) * 2,
      bonus = 0,
      tags = {
        two_handed = true,
        heavy = true,
      },
      slot = "hands",
    }
  )
end

module.gas_key = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.gas_key),
    {
      direction = "right",
      name = "Газовый ключ",
      damage_roll = D(4),
      bonus = 1,
      tags = {
        light = true,
      },
      slot = "hands",
    }
  )
end

module.yellow_gloves = function()
  return Table.extend(
    item.mixin(),
    animated(animation_packs.yellow_gloves),
    {
      direction = "right",
      name = "Огнеупорные перчатки",
      codename = "yellow_gloves",
      slot = "gloves",
    }
  )
end

module.coal = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/coal", "atlas"),
    {
      direction = "right",
      name = "Уголь",
      codename = "coal",
      slot = "underhand",
    }
  )
end

local wave_function = function(direction_name)
  return function()
    return Table.extend(
      animated("assets/sprites/animations/wave_" .. direction_name),
      {
        view = "scene",
        layer = "on_tiles",
        codename = "wave_" .. direction_name,
        on_add = function(self)
          self.animation_rate = State.water_speed / constants.DEFAULT_ANIMATION_FPS
        end,
      }
    )
  end
end

module.wave_right = wave_function("right")
module.wave_left = wave_function("left")

module.spiked_shield = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/shield", "atlas"),
    {
      direction = "right",
      name = "шипастый щит",
      damage_roll = D(6),
      bonus = 0,
      tags = {
        light = true
      },
      slot = "other_hand",
    }
  )
end

module.large_valve = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/large_valve", "atlas"),
    {
      direction = "right",
      name = "большой вентиль",
      damage_roll = D(2),
      bonus = 0,
      tags = {},
      slot = "other_hand",
    }
  )
end

module.flask = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/flask", "atlas"),
    {
      direction = "right",
      name = "фляга",
      slot = "right_pocket",
    }
  )
end

module.protective_robe = function()
  return Table.extend(
    item.mixin(),
    animated("assets/sprites/animations/protective_robe", "atlas"),
    {slot = "body"}
  )
end

return module
