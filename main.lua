local tiny = require("lib.tiny")

local world = tiny.world()

love.load = function()
  local main_font = love.graphics.newFont("fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("position", "sprite"),
    is_drawing = true,
		process = function(_, entity)
			love.graphics.print(entity.sprite.character, main_font, entity.position[1], entity.position[2])
		end,
	}))

  world:add({
    position = {400, 320},
    sprite = {
      character = "@",
    },
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

love.draw = function()
  world:update(nil, function(_, entity) return entity.is_drawing end)
end
