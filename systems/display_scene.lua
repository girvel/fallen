local CELL_DISPLAY_SIZE = 16
local main_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 7)

return Tiny.processingSystem({
  filter = function(_, e) return e.sprite and (e.position or e.off_grid_position) end,
  base_callback = "draw",

  preProcess = function()
    -- love.graphics.setBackgroundColor(utils.hex_color("332d58"))
  end,

  process = function(_, entity, state)
		state.camera:draw(function()
			local scaled_position = entity.off_grid_position
        or (entity.position - Vector({1, 1})) * CELL_DISPLAY_SIZE

			if entity.sprite.text then
				scaled_position = scaled_position + Vector({
					CELL_DISPLAY_SIZE - main_font:getWidth(entity.sprite.text),
					CELL_DISPLAY_SIZE - main_font:getHeight(),
				}) / 2

				love.graphics.print(entity.sprite.text, main_font, unpack(scaled_position))
			else
				love.graphics.draw(entity.sprite.image, unpack(scaled_position))
			end
		end)
  end,
})
