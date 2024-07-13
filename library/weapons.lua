local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")
local item = require("tech.item")


local module = {}

module.rapier = function()
  return Tablex.extend(
    item.weapon_mixin(),
    animated(animation_packs.rapier),
    {
      direction = "right",
      name = "рапира",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        finesse = true,
      },
    }
  )
end

module.greatsword = function()
  return Tablex.extend(
    item.weapon_mixin(),
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
      debug_flag = true,
    }
  )
end

module.gas_key = function()
  return Tablex.extend(
    item.weapon_mixin(),
    animated(animation_packs.gas_key),
    {
      direction = "right",
      name = "Газовый ключ",
      damage_roll = D(4),
      bonus = 1,
      tags = {},
    }
  )
end

return module
