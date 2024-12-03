local creature = require("mech.creature")
local hauler_ai = require("library.ais.hauler")
local sprite = require("tech.sprite")
local class = require("mech.class")
local body_parts = require("library.body_parts")
local fighter = require("mech.classes.fighter")
local combat_ai = require("library.ais.combat")
local player = require("state.player")
local weak_ai = require("library.ais.weak")
local humanoid = require("mech.humanoid")
local interactive = require("tech.interactive")
local items = require("library.palette.items")
local abilities = require("mech.abilities")
local races = require("mech.races")
local constants = require("mech.constants")
local general_ai = require("library.ais.general")
local janitor    = require("library.ais.janitor")


local mobs, _, static = Module("library.palette.mobs")

mobs.player = player

local dreamer_engineer_mixin = {
  max_hp = 22,
  base_abilities = abilities(16, 14, 12, 8, 8, 8),
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

    base_abilities = abilities(18, 6, 12, 8, 8, 8),
    perks = {
      class.save_proficiency("dex"),
    },

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

mobs.engineer = function(i)
  return humanoid(Table.extend(
    engineer_mixins[i],
    interactive.detector(true)
  ))
end

local dreamer_races = {races.dwarf, races.human, races.half_elf, races.half_orc, races.halfling}

mobs.old_dreamer = function()
  return humanoid({
    name = "...",
    race = Random.choice(dreamer_races),
    direction = "up",
    inventory = {},
    max_hp = 15,
    base_abilities = abilities(10, 10, 10, 10, 10, 10),
    ai = weak_ai(),
  })
end

mobs.cook = function()
  return Table.extend(
    mobs.old_dreamer(),
    interactive.detector()
  )
end

mobs.markiss = function()
  return Table.extend(
    humanoid {
      name = "Кот",
      race = races.furry,
      portrait = sprite.image("assets/sprites/portraits/markiss.png"),
      inventory = {
        head = body_parts.furry_head(),
      },
      max_hp = 15,
      base_abilities = abilities(10, 10, 10, 10, 10, 10),
      ai = hauler_ai(),
      invincible = true,
    },
    interactive.detector()
  )
end

mobs.hauler = function()
  return humanoid {
    name = "...",
    race = Random.choice(dreamer_races),
    max_hp = 15,
    base_abilities = abilities(16, 10, 10, 10, 10, 10),
    ai = hauler_ai(),
    faction = "haulers",
  }
end

mobs.dreamer = function(params)
  params = params or {}
  return Table.extend(
    humanoid({
      name = "...",
      race = params.race and races[params.race] or Random.choice(dreamer_races),
      max_hp = 15,
      hp = params.blood and 6 or nil,
      base_abilities = abilities(12, 10, 10, 10, 10, 10),
      ai = params.faction and combat_ai(),
      faction = params.faction,
      inventory = params.inventory,
    }),
    params.interactive and interactive.detector() or nil
  )
end

mobs.protected_dreamer = function()
  local result = mobs.dreamer({
    interactive = true,
    inventory = {body = items.protective_robe()},
    faction = "protected_dreamers",
  })

  result.armor_class = 17
  return result
end

mobs.janitor = function()
  return Table.extend(
    mobs.dreamer({
      inventory = {
        main_hand = items.mop(),
        other_hand = items.bucket(),
      },
    }),
    {
      name = "уборщик",
      faction = "janitor",
      ai = janitor(),
    }
  )
end

mobs.combat_dreamer = function(params)
  params = params or {}
  return Table.extend(
    humanoid {
      name = "...",
      race = Random.choice(dreamer_races),
      direction = params.direction or Random.choice(Vector.direction_names),
      faction = "guards",

      ai = combat_ai(),

      armor_class = 16,
      max_hp = 32,
      base_abilities = abilities(15, 10, 14, 7, 12, 7),
      inventory = {
        main_hand = items.mace(),
        other_hand = items.spiked_shield(),
      },
      perks = {fighter.styles.two_weapon_fighting},
    },
    interactive.detector()
  )
end

mobs.phantom_knight = function()
  return humanoid({
    ai = general_ai(),
    name = "Фантом",
    race = races.phantom,
    direction = "right",
    max_hp = 12,
    base_abilities = abilities(0, 14, 0, 0, 0, 0),
    faction = "monster",
    initiative_bonus = -30,

    on_death = Fn(),  -- disabling blood marks
  })
end

mobs.possessed = function()
  return humanoid({
    ai = general_ai(),
    name = "Потрясённый",
    race = Random.choice(dreamer_races),
    direction = "left",
    max_hp = 18,
    base_abilities = abilities(14, 13, 12, 9, 11, 10),
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

mobs.bat = function()
  return creature("assets/sprites/animations/bat", {
    codename = "bat",
    name = "летучая мышь",
    max_hp = 3,
    faction = "monster",
    race = races.bat,
  })
end

return mobs
