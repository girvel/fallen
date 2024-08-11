local animated = require("tech.animated")
local animation_packs = require("library.animation_packs")
local item = require("tech.item")
local interactive = require("tech.interactive")
local railing = require("tech.railing")
local sprite = require("tech.sprite")


local module, _, static = Module("library.items")

module.machete = function()
  return Tablex.extend(
    item.mixin(),
    animated(animation_packs.shortsword),
    {
      name = "мачете",
      damage_roll = D(6),
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

module.pole = function()
  return Tablex.extend(
    item.mixin()

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

module.note = function(page_table)
  return Tablex.extend(
    interactive(function(self)
      railing.api.discover_wiki(page_table)
      State:remove(self)
    end),
    {
      sprite = sprite.image("assets/sprites/note.png"),
      codename = "note",
      layer = "above_solids",
      view = "scene",
      name = "записка",
    }
  )
end

return module
