local utils = require("utils")

local CELL_DISPLAY_SIZE = 16
local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 16)

return Tiny.processingSystem({
  filter = Tiny.requireAll("position", "sprite"),
  base_callback = "draw",

  preProcess = function()
    -- love.graphics.setBackgroundColor(utils.hex_color("332d58"))
  end,

  process = function(_, entity, state)
		state.camera:draw(function()
			local scaled_position = (entity.position - Vector({1, 1})) * CELL_DISPLAY_SIZE + Vector({1, 1})

			if entity.sprite.character then
				scaled_position = scaled_position + Vector({
					CELL_DISPLAY_SIZE - main_font:getWidth(entity.sprite.character),
					CELL_DISPLAY_SIZE - main_font:getHeight(),
				}) / 2

				love.graphics.print(entity.sprite.character, main_font, unpack(scaled_position))
			else
				love.graphics.draw(entity.sprite.image, unpack(scaled_position))
			end
		end)
  end,
})
