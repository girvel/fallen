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

		image_data:mapPixel(function(_, _, r, g, b, a)
			if r == 1 and g == 1 and b == 1 and a == 1 then
				return unpack(color)
			else
				return 0, 0, 0, 0
			end
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

	local floor_at = function(x, y)
		world:add({
			position = Vector({x, y}),
			sprite = {
        image = colored_image("assets/sprites/floor.png", utils.hex_color("31222c"))
			}
		})
	end

  wall_at(1, 1)
  wall_at(1, 2)
  wall_at(1, 3)
  wall_at(2, 3)
  wall_at(3, 3)

  floor_at(2, 1)
  floor_at(2, 2)
  floor_at(3, 1)
  floor_at(3, 2)

  game_state.grid[Vector({2, 2})] = world:add({
    position = Vector({2, 2}),
    sprite = {
      character = "@",
    },
    player_flag = true,
    turn_resources = {
      movement = 6,
      movement_max = 6,
    },
  })

end

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

love.errorhandler = function(msg)
  Log.fatal(msg)
end
