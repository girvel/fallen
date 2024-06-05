local stateful = require("tech.stateful")


local no_transform = love.math.newTransform()

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
    if not entity.sprite.image then return end

    love.graphics.applyTransform(state.transform)

    local scaled_position = ((entity.position - Vector({1, 1})) * state.CELL_DISPLAY_SIZE):ceil()
    love.graphics.draw(entity.sprite.image, unpack(scaled_position))

    love.graphics.replaceTransform(no_transform)
  end,
})
