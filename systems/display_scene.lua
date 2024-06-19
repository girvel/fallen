local level = require("tech.level")
local no_transform = love.math.newTransform()

return Tiny.system({
  filter = Tiny.requireAll("sprite", "position"),
  base_callback = "draw",

  old_camera_position = Vector.zero,

  update = function(self, state, event)
    local window_w = love.graphics.getWidth() / state.SCALING_FACTOR
    local window_h = love.graphics.getHeight() / state.SCALING_FACTOR
    local border_w = math.floor(window_w / 3)
    local border_h = math.floor(window_h / 3)
    local player_x, player_y = unpack(state.player.position * state.CELL_DISPLAY_SIZE)
    local grid_w, grid_h = unpack(state.grids.solids.size * state.CELL_DISPLAY_SIZE)

    state.camera.position = Vector({
      Mathx.median(
        0,
        player_x - window_w + border_w,
        state.camera.position[1],
        player_x - border_w,
        grid_w - window_w
      ),
      Mathx.median(
        0,
        player_y - window_h + border_h,
        state.camera.position[2],
        player_y - border_h,
        grid_h - window_h
      )
    })

    state.transform:translate(unpack(self.old_camera_position - state.camera.position))
    self.old_camera_position = state.camera.position

    local grid_size = state.grids.solids.size
    for _, l in ipairs(level.GRID_LAYERS) do
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
