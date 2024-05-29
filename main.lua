Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")


local world = Tiny.world()

love.load = function()
  Log.info("Game started")

  local CELL_DISPLAY_SIZE = 20
  local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)

  world:add(Tiny.processingSystem({
		filter = Tiny.requireAll("position", "sprite"),
    base_callback = "draw",
		process = function(_, entity)
			love.graphics.print(entity.sprite.character, main_font, unpack(entity.position * CELL_DISPLAY_SIZE))
		end,
	}))

  local movement_hotkeys = {
    w = Vector({0, -1}),
    a = Vector({-1, 0}),
    s = Vector({0, 1}),
    d = Vector({1, 0}),
  }
  local turn_skip_hotkey = "space"
	world:add(Tiny.processingSystem({
		filter = Tiny.requireAll("player_flag"),
    base_callback = "keypressed",
		process = function(_, entity, _, event)
      local _, scancode = unpack(event)

      if scancode == turn_skip_hotkey then
        entity.turn_resources.movement = entity.turn_resources.movement_max
        return
      end

      local movement = movement_hotkeys[scancode]
      if movement == nil or entity.turn_resources.movement <= 0 then return end
      entity.position = entity.position + movement
      entity.turn_resources.movement = entity.turn_resources.movement - 1
		end,
	}))

  world:add({
    position = Vector({20, 16}),
    sprite = {
      character = "@",
    },
    player_flag = true,
    turn_resources = {
      movement = 6,
      movement_max = 6,
    },
  })

  world:add({
    position = Vector({19, 16}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = Vector({19, 15}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = Vector({19, 17}),
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

