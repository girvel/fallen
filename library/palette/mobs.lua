local player = require("state.player")
local weak_ai = require("library.weak_ai")
local humanoid = require("mech.humanoid")
local interactive = require("tech.interactive")
local items = require("library.palette.items")
local abilities = require("mech.abilities")
local races = require("mech.races")
local constants = require("mech.constants")
local general_ai = require("library.general_ai")


local module, _, static = Module("library.palette.mobs")

module.player = player


local dreamer_engineer_mixin = {
  max_hp = 22,
  abilities = abilities(16, 14, 12, 8, 8, 8),
  faction = "dreamers_detective",
}

-- [{7, 9}] = {"down", {main_hand = items.gas_key()}},
-- [{5, 8}] = {"down"},
-- [{5, 3}] = {"up", {gloves = items.yellow_gloves()}},
-- [{8, 3}] = {"up"},

local engineer_mixins = {
  Table.extend({
    name = "инженер-полуэльф",
    race = races.half_elf,
    direction = "down",
    inventory = {main_hand = items.gas_key()},
    ai = general_ai(),
  }, dreamer_engineer_mixin),
  Table.extend({
    name = "инженер-полурослик",
    race = races.halfling,
    direction = "down",
    inventory = {},
    ai = general_ai(),
  }, dreamer_engineer_mixin),
  {
    name = "инженер-полуорк",
    race = races.half_orc,
    hp = 34,
    max_hp = 35,
    direction = "up",
    inventory = {gloves = items.yellow_gloves()},
    faction = "half_orc",

    abilities = abilities(18, 6, 12, 8, 8, 8),
    save_proficiencies = {dex = true},

    interacted_by = nil,
    will_beg = true,

    ai = general_ai(true),

    get_resources = function()
      return {
        movement = constants.DEFAULT_MOVEMENT_SPEED,
        actions = 2,
        bonus_actions = 1,
        reactions = 1,
      }
    end,
  },
  Table.extend({
    name = "инженер-дворф",
    race = races.dwarf,
    direction = "up",
    inventory = {},
    ai = general_ai(),
  }, dreamer_engineer_mixin),
}

module.engineer = function(i)
  return humanoid(Table.extend(engineer_mixins[i], interactive.detector()))
end

local dreamer_races = {races.dwarf, races.human, races.half_elf, races.half_orc, races.halfling}

module.old_dreamer = function()
  return humanoid({
    name = "...",
    race = Random.choice(dreamer_races),
    direction = "up",
    inventory = {},
    max_hp = 15,
    abilities = abilities(10, 10, 10, 10, 10, 10),
    ai = weak_ai(),
  })
end

module.cook = function()
  return Table.extend(
    module.old_dreamer(),
    interactive.detector(true)
  )
end

module.dreamer = function()
  return humanoid({
    name = "...",
    race = Random.choice(dreamer_races),
    direction = "up",
    inventory = {},
    max_hp = 15,
    abilities = abilities(10, 10, 10, 10, 10, 10),
  })
end

module.phantom_knight = function()
  return humanoid({
    ai = general_ai(),
    name = "Фантом",
    race = races.phantom,
    direction = "right",
    max_hp = 12,
    abilities = abilities(0, 14, 0, 0, 0, 0),
    faction = "monster",
    initiative_bonus = -30,
  })
end

module.possessed = function()
  return humanoid({
    ai = general_ai(),
    name = "Потрясённый",
    race = Random.choice(dreamer_races),
    direction = "left",
    max_hp = 18,
    abilities = abilities(14, 13, 12, 9, 11, 10),
    faction = "monster",
    inventory = {main_hand = {
      damage_roll = D(8),
      bonus = 0,
      tags = {},
      slot = "hands",
      disable_drop_flag = true,
    }},
    initiative_bonus = 10,
  })
end

return module
