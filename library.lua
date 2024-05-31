local level = require("level")
local utils = require("utils")

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

local move = function(direction)
  return function(entity, state)
    if (
      entity.turn_resources.movement > 0 and
      level.move(state.grid, entity, entity.position + direction)
    ) then
      entity.turn_resources.movement = entity.turn_resources.movement - 1
    end
  end
end

local hotkeys = {
  w = move(Vector({0, -1})),
  a = move(Vector({-1, 0})),
  s = move(Vector({0, 1})),
  d = move(Vector({1, 0})),

  space = function()
    return true
  end,

  f = function(entity, state)
    if entity.turn_resources.actions <= 0 then return end
    local target = state.grid[entity.position + Vector.right]
    if not target or not target.hp then return end
    target.hp = target.hp - 1
    if target.hp <= 0 then
      Log.warn("someone is killed, but there is no system for that yet")
      state.grid[target.position] = nil
    end
    entity.turn_resources.actions = entity.turn_resources.actions - 1
  end,
}

module.player = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/fighter.png"),
    },
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
  }
end

module.bat = function()
  return {
    hp = 2,
    sprite = {
      image = love.graphics.newImage("assets/sprites/bat.png")
    },
    turn_resources = {
      movement = 6,
      actions = 1,
    },
    ai = function(self, state)
      if utils.chance(0.5) then
        return true
      end
      move(Vector(utils.choice({
        {1, 0}, {0, 1}, {-1, 0}, {0, -1},
      })))(self, state)
    end,
  }
end

module.smooth_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  }
end

return module
