-- TODO fixed size cells, vectors
-- TODO basic WASD movement

local tiny = require("lib.tiny")
local vector = require("lib.vector")
local log = require("lib.log")


local world = tiny.world()

love.load = function()
  log.info("Game started")

  local main_font = love.graphics.newFont("fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("position", "sprite"),
    base_callback = "draw",
		process = function(_, entity)
			love.graphics.print(entity.sprite.character, main_font, entity.position[1], entity.position[2])
		end,
	}))

  local movement_hotkeys = {
    w = vector({0, -20}),
    a = vector({-20, 0}),
    s = vector({0, 20}),
    d = vector({20, 0}),
  }
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("player_flag"),
    base_callback = "keypressed",
		process = function(event, entity)
      local movement = movement_hotkeys[event[2]]
      if movement == nil then return end
      entity.position = entity.position + movement
		end,
	}))

  world:add({
    position = vector({400, 320}),
    sprite = {
      character = "@",
    },
    player_flag = true,
  })

  world:add({
    position = vector({380, 320}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = vector({380, 300}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = vector({380, 340}),
    sprite = {
      character = "#",
    },
  })
end

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update({...}, function(_, entity) return entity.base_callback == callback_name end)
  end
end

