local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")
local item = require("tech.item")


local module, _, static = Module("library.weapons")

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
      slot = "hands",
    }
  )
end

module.dagger = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.dagger),
    {
      name = "кинжал",
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
      slot = "hands",
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
      tags = {
        light = true,
      },
      slot = "hands",
    }
  )
end

module.yellow_gloves = function()
  return Tablex.extend(
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

return module
