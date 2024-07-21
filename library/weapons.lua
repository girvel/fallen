local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")
local item = require("tech.item")


local module = {}

module.rapier = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.rapier),
    {
      name = "рапира",
      damage_roll = D(8),
      bonus = 0,
      tags = {
        finesse = true,
      },
      slot = "main_hand",
    }
  )
end

module.dagger = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.dagger),
    {
      name = "кинжал",
      damage_roll = D(40),
      bonus = 0,
      tags = {
        finesse = true,
      },
      slot = "main_hand",
    }
  )
end

module.greatsword = function()
  return Tablex.extend(
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
      slot = "main_hand",
    }
  )
end

module.gas_key = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.gas_key),
    {
      direction = "right",
      name = "Газовый ключ",
      damage_roll = D(4),
      bonus = 1,
      tags = {},
      slot = "main_hand",
    }
  )
end

module.yellow_glove = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.yellow_glove),
    {
      direction = "right",
      name = "Огнеупорные перчатки",
      codename = "yellow_glove",
      slot = "gloves",
    }
  )
end

return module
