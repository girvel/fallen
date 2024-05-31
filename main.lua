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

	local colored_image = function(path, color)
		local image_data = love.image.newImageData(path)

		image_data:mapPixel(function(_, _, _, _, _, a)
      if a == 0 then return 0, 0, 0, 0 end
      return unpack(color)
		end)

		return love.graphics.newImage(image_data)
	end

  local wall_at = function(x, y)
    local v = Vector({x, y})
    game_state.grid[v] = world:add({
      position = v,
      sprite = {
        image = colored_image("assets/sprites/wall.png", utils.hex_color("402b55")),
      },
    })
  end

	local planks_at = function(x, y)
		world:add({
			position = Vector({x, y}),
			sprite = {
        image = colored_image("assets/sprites/planks.png", utils.hex_color("31222c"))
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
  }

  game_state.grid[Vector({2, 2})] = world:add({
    position = Vector({2, 2}),
    sprite = {
      character = "@",
    },
    turn_resources = {
      movement = 6,
    },
    ai = function(self, state)
      local action = hotkeys[self.last_pressed_key]
      self.last_pressed_key = nil
      if action ~= nil then return action(self, state) end
    end,
  })

  game_state.player = game_state.grid[Vector({2, 2})]

  game_state.grid[Vector({5, 5})] = world:add({
    position = Vector({5, 5}),
    sprite = {
      character = "b",
    },
    turn_resources = {
      movement = 6,
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
