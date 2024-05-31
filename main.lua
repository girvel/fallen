Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")

local gamera = require("lib.gamera")
local utils = require("utils")


local world, game_state
love.load = function()
  Log.info("Game started")

	game_state = {
		grid = Grid(Vector({10, 10})),
		camera = gamera.new(0, 0, 9999, 9999),
	}
	game_state.camera:setScale(2)
	game_state.camera:setPosition(0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")

  world = Tiny.world(unpack(require("systems")))

  local wall_at = function(x, y)
    local v = Vector({x, y})
    game_state.grid[v] = world:add({
      position = v,
      sprite = {
        image = love.graphics.newImage("assets/sprites/wall.png"),
      },
    })
  end

	local planks_at = function(x, y)
		world:add({
			position = Vector({x, y}),
			sprite = {
        image = love.graphics.newImage("assets/sprites/planks.png")
			}
		})
	end

  local grass_at = function(x, y)
		world:add({
			position = Vector({x, y}),
			sprite = {
        image = love.graphics.newImage("assets/sprites/grass.png")
			}
		})
  end

  wall_at(1, 1)
  wall_at(1, 2)
  wall_at(1, 3)
  wall_at(2, 3)
  wall_at(3, 3)

  planks_at(2, 1)
  planks_at(2, 2)
  planks_at(3, 1)
  planks_at(3, 2)

  grass_at(1, 4)
  grass_at(2, 4)
  grass_at(3, 4)

  local move = function(direction)
    return function(entity, state)
      if entity.turn_resources.movement <= 0 then return end
      local next_position = entity.position + direction
      if not state.grid:can_fit(next_position) or state.grid[next_position] ~= nil then return end

      state.grid[next_position] = entity
      state.grid[entity.position] = nil
      entity.position = next_position
      entity.turn_resources.movement = entity.turn_resources.movement - 1
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
        world:remove(target)
        state.grid[target.position] = nil
      end
      entity.turn_resources.actions = entity.turn_resources.actions - 1
    end,
  }

  game_state.grid[Vector({2, 2})] = world:add({
    position = Vector({2, 2}),
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
  })

  game_state.player = game_state.grid[Vector({2, 2})]

  game_state.grid[Vector({5, 5})] = world:add({
    hp = 2,
    position = Vector({5, 5}),
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
  })

  game_state.grid[Vector({4, 3})] = world:add({
    position = Vector({4, 3}),
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  })

  game_state.move_order = {
    list = {
      game_state.grid[Vector({2, 2})],
      game_state.grid[Vector({5, 5})],
    },
    current_i = 1,
  }
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

love.errorhandler = function(msg)
  Log.fatal(msg)
end
