local stateful = require("tech.stateful")


local CELL_DISPLAY_SIZE = 16
local default_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 7)

return Tiny.system({
  filter = Tiny.requireAll("sprite", "position"),
  base_callback = "draw",

  update = function(self, state, event)
    local grid_size = state.grids.solids.size
    for _, l in ipairs(stateful.GRID_LAYERS) do
      for x = 1, grid_size[1] do
        for y = 1, grid_size[2] do
          local entity = state.grids[l][Vector({x, y})]

          if entity and self:filter(entity) then
            self:process(entity, state, event)
          end
        end
      end
    end
  end,

  process = function(_, entity, state)
    if entity.off_grid_position then
      local position = Vector({state.camera:toScreen(unpack(entity.off_grid_position))})
        + Vector({
          CELL_DISPLAY_SIZE - default_font:getWidth(entity.sprite.text),
          CELL_DISPLAY_SIZE - default_font:getHeight(),
        }) / 2

      love.graphics.print(
        {entity.sprite.color, entity.sprite.text},
        entity.sprite.font or default_font,
        unpack(position)
      )

      return
    end

    if not entity.sprite.image then return end

    love.graphics.applyTransform(state.transform)

    local scaled_position = ((entity.position - Vector({1, 1})) * CELL_DISPLAY_SIZE):ceil()
    love.graphics.draw(entity.sprite.image, unpack(scaled_position))

    love.graphics.replaceTransform(love.math.newTransform())
  end,
})
