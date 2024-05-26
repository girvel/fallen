-- TODO fixed size cells, vectors
-- TODO basic WASD movement

local tiny = require("lib.tiny")

local world = tiny.world()

love.load = function()
  local main_font = love.graphics.newFont("fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("position", "sprite"),
    base_callback = "draw",
		process = function(_, entity)
			love.graphics.print(entity.sprite.character, main_font, entity.position[1], entity.position[2])
		end,
	}))

	world:add(tiny.processingSystem({
		filter = tiny.requireAll("player_flag"),
    base_callback = "keypressed",
		process = function(_, entity)
      entity.position[1] = entity.position[1] + 20
		end,
	}))

  world:add({
    position = {400, 320},
    sprite = {
      character = "@",
    },
    player_flag = true,
  })

  world:add({
    position = {380, 320},
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = {380, 300},
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = {380, 340},
    sprite = {
      character = "#",
    },
  })
end

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function() -- TODO pass varargs downwards
    world:update(nil, function(_, entity) return entity.base_callback == callback_name end)
  end
end

