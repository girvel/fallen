local level = require("level")
local random = require("utils.random")
local common = require("utils.common")


local module = {}

module.wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/wall.png"),
    },
  }
end

module.planks = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/planks.png")
    }
  }
end

module.grass = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/grass.png")
    }
  }
end

local get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

-- TODO extract abstract shit
module.get_turn_resources = function(creature)
  return {
    movement = 6,
    actions = 1,
  }
end

-- TODO extract abstract shit
module.creature = function()
  return {
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    abilities = {
      strength = 10,
      dexterity = 10,
    },

    get_armor = function(self)
      return 10 + get_modifier(self.abilities.dexterity)
    end,
  }
end

local move = function(direction_name)
  return function(entity, state)
    if (
      entity.turn_resources.movement > 0 and
      level.move(state.grids[entity.layer], entity, entity.position + Vector[direction_name])
    ) then
      entity.turn_resources.movement = entity.turn_resources.movement - 1

      if entity.animation then
        entity.animation.current = "move_" .. direction_name
        entity.animation.frame = 0
      end
    end
  end
end

local hand_attack = function(entity, state, target)
  if entity.turn_resources.actions <= 0 then return end
  if not target or not target.hp then return end
  entity.turn_resources.actions = entity.turn_resources.actions - 1

  local attack_roll = random.d(20) + get_modifier(entity.abilities.strength)
  Log.info(
    entity.name .. " attacks " .. target.name .. "; attack roll: " ..
    attack_roll .. ", armor: " .. target:get_armor()
  )

  if attack_roll < target:get_armor() then return end

  local damage = math.max(1, (entity.abilities.strength - 10) / 2)
  Log.info("damage: " .. damage)

  target.hp = target.hp - damage
  if target.hp <= 0 then
    state:remove(target)
    Log.info(target.name .. " is killed")
  end
end

local hotkeys = {
  w = move("up"),
  a = move("left"),
  s = move("down"),
  d = move("right"),

  space = function()
    return true
  end,

  f = function(entity, state)
    return hand_attack(entity, state, state.grids.solids[entity.position + Vector.right])
  end,
}

local player_character_pack = {
  idle = {
    love.graphics.newImage("assets/sprites/player_character.png"),
  },
  move_right = {
    love.graphics.newImage("assets/sprites/player_character_walk01.png"),
    love.graphics.newImage("assets/sprites/player_character_walk02.png"),
  },
}

module.player = function()
  return common.extend(module.creature(), {
    name = "player",
    sprite = {
      image = love.graphics.newImage("assets/sprites/player_character.png"),
    },
    animation = {
      pack = player_character_pack,
      current = "idle",
      frame = 1,
    },
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
    abilities = {
      strength = 12,
      dexterity = 10,
    },
  })
end

module.bat = function()
  return common.extend(module.creature(), {
    name = "bat",
    hp = 2,
    sprite = {
      image = love.graphics.newImage("assets/sprites/bat.png")
    },
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    ai = function(self, state)
      if random.chance(0.5) then
        return true
      end
      move(random.choice({"up", "down", "left", "right"}))(self, state)
    end,
  })
end

module.smooth_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  }
end

return module
