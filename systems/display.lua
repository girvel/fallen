local animated = require("tech.animated")
local level = require("state.level")
local tcod = require("tech.tcod")
local line_profiler = require("lib.line_profiler")


--- @param position vector_base
--- @param size vector_base
--- @param color color
--- @return nil
local display_rectangle = function(position, size, color)
  love.graphics.setColor(color)
  local x, y = unpack(position)
  love.graphics.rectangle("fill", x, y, unpack(size))
  love.graphics.setColor(Colors.absolute_white)
end

local default_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12)
default_font:setLineHeight(1.2)

local hint_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 16)


--- @class displayable: entity
--- @field position vector
--- @field sprite sprite
--- @field view string

local display, _, static = Module("systems.display")

display.system = static(Tiny.sortedProcessingSystem({
  codename = "display",
  filter = function(self, e) return e.position and e.sprite and e.view and e.view ~= "scene" end,
  base_callback = "draw",

  compare = function(self, first, second)
    if first.view ~= second.view then
      local iterator = Fun.iter(State.gui.views_order):enumerate()
      local first_i = iterator:filter(function(i, name) return name == first.view end):nth(1)
      local second_i = iterator:filter(function(i, name) return name == second.view end):nth(1)
      if not first_i or not second_i then
        local nil_view = first.view
        if not second_i then
          nil_view = second.view
        end
        Log.error("View %s is unordered" % nil_view)
      end
      return first_i < second_i
    end
  end,

  preProcess = function(self, dt)
    State.gui:update(dt)
    self:process_grid()
  end,

  process_grid = function(self)
    if not State.mode:get().displayed_views.scene then return end
    love.graphics.setShader(-Query(State.shader).love_shader)

    -- borders --
    local view = State.gui.views.scene
    local _start = -(view.offset / view:get_multiplier()):map(math.floor)
    local _finish = _start + (
      Vector({love.graphics.getDimensions()}) / view:get_multiplier()
    ):map(math.ceil)

    local start = Vector.use(Math.median, Vector.one, _start - Vector.one, State.grids.solids.size)
    local finish = Vector.use(Math.median, Vector.one, _finish, State.grids.solids.size)

    -- mask --
    local snapshot = tcod.snapshot()

    if State.player.fov_radius == 0 then
      self:process(State.player)
      return
    end

    snapshot:refresh_fov()

    for x = start[1], finish[1] do
      for y = start[2], finish[2] do
        if not snapshot:is_visible_unsafe(x, y) or State.grids.tiles:fast_get(x, y) then
          goto continue
        end

        local x1, y1 = State.gui.views.scene:apply_scalar(x, y)
        self:_process_image_sprite(
          State.background_dummy,
          x1, y1,
          State.gui.views.scene.scale
        )
        ::continue::
      end
    end

    for _, layer in ipairs(level.GRID_LAYERS) do
      local grid = State.grids[layer]
      for x = start[1], finish[1] do
        for y = start[2], finish[2] do
          if not snapshot:is_visible_unsafe(x, y) then goto continue end

          local cell = grid:fast_get(x, y)
          if not cell then goto continue end

          if not level.GRID_COMPLEX_LAYERS[layer] then cell = {cell} end
          for _, e in ipairs(cell) do
            local is_hidden_by_perspective = (
              not snapshot:is_transparent_unsafe(x, y)
              and e.perspective_flag
              and e.position[2] > State.player.position[2]
            )
            if not is_hidden_by_perspective then
              self:process(e)
            end
          end
          ::continue::
        end
      end
    end

    love.graphics.setShader()
    Query(self.shader):deactivate()
  end,

  --- @param entity displayable
  process = function(self, entity)
    if
      not State.mode:get().displayed_views[entity.view]
      or State.gui.sidebar._hidden
        and Table.contains({"sidebar", "sidebar_text", "sidebar_background"}, entity.view)
    then
      return
    end

    local current_view = State.gui.views[entity.view]
    local offset_position = current_view:apply(animated.get_render_position(entity))

    if entity.shader then
      love.graphics.setShader(entity.shader.love_shader)
      Query(entity.shader):preprocess(entity)
    else
      Query(State.shader):preprocess(entity)
    end

    if entity.sprite.text then
      self:_process_text_sprite(entity, offset_position)
    elseif entity.sprite.image then
      local x, y = unpack(offset_position)
      self:_process_image_sprite(entity, x, y, current_view.scale)
    elseif entity.sprite.rect_color then
      display_rectangle(
        offset_position,
        entity.size * current_view:get_multiplier(),
        entity.sprite.rect_color
      )
    else
      -- error("Wrong sprite format of %s:\n%s" % {Entity.name(entity), Inspect(entity.sprite)})
    end

    if entity.shader then
      love.graphics.setShader(-Query(State.shader).love_shader)
    end
  end,

  _process_text_sprite = function(self, entity, offset_position)
    love.graphics.print(entity.sprite.text, entity.sprite.font, unpack(offset_position))

    if entity.link_flag then
      local view = State.gui.views[entity.view]
      local start = offset_position + Vector.down * entity.size[2]
      local finish = offset_position + entity.size * view:get_multiplier()
      local mouse_position = Vector({love.mouse.getPosition()})
      if not (mouse_position >= offset_position and mouse_position < finish) then return end

      if type(entity.sprite.text) == "table" then
        love.graphics.setColor(entity.sprite.text[1])
      end
      love.graphics.line(start[1], start[2], unpack(finish))
      love.graphics.setColor(Colors.absolute_white)
    end
  end,

  _process_image_sprite = function(self, entity, x, y --[[for optimization]], scale)
    local display_slot = function(slot)
      local item_sprite = -Query(entity.inventory)[slot].sprite
      if not item_sprite then return end

      local entity_anchor = -Query(entity.sprite).anchors[slot]
      local item_anchor = -Query(item_sprite).anchors.parent
      local item_x, item_y = x, y
      if item_anchor and entity_anchor then
        local offset = (entity_anchor - item_anchor) * scale
        item_x = item_x + offset[1]
        item_y = item_y + offset[2]
      end
      love.graphics.draw(item_sprite.image, item_x, item_y, 0, scale)
    end

    local is_main_hand_in_background, is_other_hand_in_background
    if entity.inventory then
      is_main_hand_in_background = entity.direction == "up"
      is_other_hand_in_background = entity.direction ~= "down"
      if is_main_hand_in_background then display_slot("main_hand") end
      if is_other_hand_in_background then display_slot("other_hand") end
    end

    if entity.sprite.quad then
      love.graphics.draw(entity.sprite.image, entity.sprite.quad, x, y, 0, scale)
    else
      love.graphics.draw(entity.sprite.image, x, y, 0, scale)
    end

    if entity.inventory then
      display_slot("head")
      display_slot("blood")
      display_slot("gloves")
      display_slot("underhand")
      if not is_main_hand_in_background then display_slot("main_hand") end
      if not is_other_hand_in_background then display_slot("other_hand") end
      display_slot("highlight")
    end
  end,

  postProcess = function(self)
    -- This is fine to be hardcoded
    if State.gui.show_fps then
      love.graphics.print("FPS: %.2f" % (1 / love.timer.getAverageDelta()), default_font, 5, 5)
    end

    -- TODO probably all this bullshit should be handled through entities, not hardcoded display
    --   functions
    local mode = State.mode:get()
    if mode == State.mode.text_input then return State.gui.text_input:display() end
    if mode == State.mode.death then return self:_display_death_message() end
    self:_display_hint()
    if mode == State.mode.reading or State.shader or State.gui.disable_ui then return end
    self:_display_text_info()
  end,

  _display_death_message = function(self)
    local draw_centered = function(message, font, x, y)
      love.graphics.print(
        message,
        font,
        (love.graphics.getWidth() - font:getWidth(message)) / 2 + x,
        (love.graphics.getHeight() - font:getHeight()) / 2 + y
      )
    end

    local scale = 16
    local x, y = unpack((Vector({love.graphics.getDimensions()})
      - Vector({State.player.sprite.image:getDimensions()}) * scale) / 2
      + Vector.up * 200)
    self:_process_image_sprite(State.player, x, y, scale)

    local heading_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 72)
    local subheading_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 24)
    draw_centered("Game over", heading_font, 0, 0)
    draw_centered("[Enter] — начать с последнего сохранения", subheading_font, 0, 80)
    draw_centered("[R] — начать игру заново", subheading_font, 0, 110)
    draw_centered("[Ctrl + D] — завершить игру", subheading_font, 0, 140)
  end,

  _display_text_info = function(self)
    if State.gui.sidebar._hidden then return end
    love.graphics.printf(
      State.gui.sidebar:get_text(), default_font,
      love.graphics.getWidth() - State.gui.sidebar.W, 300,
      State.gui.sidebar.W - 15
    )
  end,

  _display_hint = function(self)
    local content = State.gui.hint:get()
    local x = (love.graphics.getWidth() - hint_font:getWidth(content)) / 2
    local y = love.graphics.getHeight() - hint_font:getHeight() - 50

    display_rectangle(
      {x, y},
      {hint_font:getWidth(content), hint_font:getHeight()},
      Colors.black
    )

    love.graphics.print({Colors.gray, content}, hint_font, x, y)
  end,
}))

return display
