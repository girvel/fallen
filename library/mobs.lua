local humanoid = require("mech.humanoid")
local interactive = require("tech.interactive")
local items = require("library.items")
local abilities = require("mech.abilities")
local races = require("mech.races")
local constants = require("mech.constants")
local general_ai = require("library.general_ai")


local module, _, static = Module("library.mobs")

local engineer_mixin = function(ai_outside_of_combat)
  return Table.extend(
    interactive.detector(),
    {
      ai = general_ai(ai_outside_of_combat),
    }
  )
end

local dreamer_engineer_mixin = function()
  return Table.extend(
    engineer_mixin(),
    {
      max_hp = 22,
      abilities = abilities(16, 14, 12, 8, 8, 8),
      faction = "dreamers_detective",
    }
  )
end

-- [{7, 9}] = {"down", {main_hand = items.gas_key()}},
-- [{5, 8}] = {"down"},
-- [{5, 3}] = {"up", {gloves = items.yellow_gloves()}},
-- [{8, 3}] = {"up"},

module[1] = function()
  return humanoid(Table.extend({
    name = "инженер-полуэльф",
    race = races.half_elf,
    direction = "down",
    inventory = {main_hand = items.gas_key()},
  }, dreamer_engineer_mixin()))
end

module[2] = function()
  return humanoid(Table.extend({
    name = "инженер-полурослик",
    race = races.halfling,
    direction = "down",
    inventory = {},
  }, dreamer_engineer_mixin()))
end

module[3] = function()
  return humanoid(Table.extend({
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

    get_resources = function()
      return {
        movement = constants.DEFAULT_MOVEMENT_SPEED,
        actions = 2,
        bonus_actions = 1,
        reactions = 1,
      }
    end,
  }, engineer_mixin(true)))
end

module[4] = function()
  return humanoid(Table.extend({
    name = "инженер-дворф",
    race = races.dwarf,
    direction = "up",
    inventory = {},
  }, dreamer_engineer_mixin()))
end

local dreamer_races = {races.dwarf, races.human, races.half_elf, races.half_orc, races.halfling}

module.dreamer = function()
  return humanoid({
    name = "...",
    race = Random.choice(dreamer_races),
    direction = "up",
    inventory = {},
    max_hp = 15,
    abilities = abilities(10, 10, 10, 10, 10, 10),
    faction = "dreamers_detective",
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
