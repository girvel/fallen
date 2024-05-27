local tiny = require("lib.tiny")
local vector = require("lib.vector")
local log = require("lib.log")


local world = tiny.world()

love.load = function()
  log.info("Game started")

  local CELL_DISPLAY_SIZE = 20
  local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("position", "sprite"),
    base_callback = "draw",
		process = function(_, entity)
			love.graphics.print(entity.sprite.character, main_font, unpack(entity.position * CELL_DISPLAY_SIZE))
		end,
	}))

  local movement_hotkeys = {
    w = vector({0, -1}),
    a = vector({-1, 0}),
    s = vector({0, 1}),
    d = vector({1, 0}),
  }
	world:add(tiny.processingSystem({
		filter = tiny.requireAll("player_flag"),
    base_callback = "keypressed",
		process = function(_, entity, _, event)
      local movement = movement_hotkeys[event[2]]
      if movement == nil then return end
      entity.position = entity.position + movement
		end,
	}))

  world:add({
    position = vector({20, 16}),
    sprite = {
      character = "@",
    },
    player_flag = true,
  })

  world:add({
    position = vector({19, 16}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = vector({19, 15}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = vector({19, 17}),
    sprite = {
      character = "#",
    },
  })
end

local game_state = {}

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

