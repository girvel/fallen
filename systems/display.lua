local animated = require("tech.animated")
local level = require("state.level")
local tcod = require("lib.tcod")


local default_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12)
default_font:setLineHeight(1.2)

local hint_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 16)

local display, _, static = Module("systems.display")

display.system = static(Tiny.sortedProcessingSystem({
  codename = "display",
  filter = function(self, e) return e.position and e.sprite and e.view and e.view ~= "scene" end,
  base_callback = "draw",

  _fov_map = nil,

  compare = function(self, first, second)
    if first.view ~= second.view then
      local iterator = Fun.iter(State.gui.views_order):enumerate()
      local first_i = iterator:filter(function(i, name) return name == first.view end):nth(1)
      local second_i = iterator:filter(function(i, name) return name == second.view end):nth(1)
      return first_i < second_i
    end
  end,

  preProcess = function(self, event)
    State.gui:update_views()
    State.gui.sidebar:update_indicators(event[1])
    self:process_grid(event)
  end,

  process_grid = function(self, event)
    if Table.contains({"character_creator", "reading", "death", "text_input"}, State:get_mode()) then return end

    -- borders --
    local view = State.gui.views.scene
    local _start = -(view.offset / view:get_multiplier()):map(math.floor)
    local _finish = _start + (Vector({love.graphics.getDimensions()}) / view:get_multiplier()):map(math.ceil)

    local start = Vector.use(Math.median, Vector.one, _start, State.grids.solids.size)
    local finish = Vector.use(Math.median, Vector.one, _finish, State.grids.solids.size)

    -- mask --
    local solids = State.grids.solids
    if not self._fov_map then
      self._fov_map = tcod.TCOD_map_new(unpack(solids.size))
    end

    local function bool(x)
      return not not x
    end

    for x = start[1], finish[1] do
      for y = start[2], finish[2] do
        local e = solids:safe_get(Vector({x, y}))
        tcod.TCOD_map_set_properties(self._fov_map, x, y, bool(not e or e.transparent_flag), not e)
      end
    end

    if State.player.fov_radius == 0 then
      self:process(State.player)
      return
    end

    local px, py = unpack(State.player.position)
    tcod.TCOD_map_compute_fov(self._fov_map, px, py, State.player.fov_radius, true, tcod.FOV_PERMISSIVE_8)

    for x = _start[1], _finish[1] do
      for y = _start[2], _finish[2] do
        local p = Vector({x, y})
        if tcod.TCOD_map_is_in_fov(self._fov_map, x, y)
          and not State.grids.tiles:safe_get(p) then
            self:_process_image_sprite(
              State.background_dummy,
              State.gui.views.scene:apply(p),
              State.gui.views.scene.scale
            )
        end
      end
    end

    for _, layer in ipairs(level.GRID_LAYERS) do
      local grid = State.grids[layer]
      for x = start[1], finish[1] do
        for y = start[2], finish[2] do
          if tcod.TCOD_map_is_in_fov(self._fov_map, x, y) then
            local cell = grid:fast_get(x, y)
            if level.GRID_COMPLEX_LAYERS[layer] then
              for _, e in ipairs(cell) do
                if e then self:process(e) end
              end
            else
              if cell then
                self:process(cell)
              end
            end
          end
        end
      end
    end
  end,

  process = function(self, entity)
    local mode = State:get_mode()
    if
      State.gui.disable_ui and not Table.contains({"scene", "dialogue_text"}, entity.view)
      -- TODO this should be grouped w/ views?
      or mode == "character_creator" and not Table.contains(
        {"sidebar", "sidebar_text", "sidebar_background", "character_creator",
         "actions", "action_frames", "action_keys"},
        entity.view
      )
      or mode == "reading" and not Table.contains(
        {"sidebar", "sidebar_text", "sidebar_background", "wiki",
         "actions", "action_frames", "action_keys"},
        entity.view
      )
      or mode == "death"
      or mode == "text_input"
    then return end

    local current_view = State.gui.views[entity.view]
    local offset_position = current_view:apply(animated.get_render_position(entity))

    local old_shader
    if entity.shader then
      old_shader = State.shader
      State:set_shader(entity.shader)
    end

    if entity.sprite.text then
      self:_process_text_sprite(entity, offset_position)
    elseif entity.sprite.image then
      self:_process_image_sprite(entity, offset_position, current_view.scale)
    elseif entity.sprite.rect_color then
      local x, y = unpack(offset_position)
      love.graphics.setColor(entity.sprite.rect_color)
      love.graphics.rectangle("fill", x, y, unpack(entity.size * current_view:get_multiplier()))
      love.graphics.setColor(Colors.absolute_white)
    else
      -- error("Wrong sprite format of %s:\n%s" % {Common.get_name(entity), Inspect(entity.sprite)})
    end

    if entity.shader then
      State:set_shader(old_shader)
    end
  end,

  _process_text_sprite = function(self, entity, offset_position)
    if State.shader then return end
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

  _process_image_sprite = function(self, entity, offset_position, scale)
    local display_slot = function(slot)
      local item_sprite = -Query(entity.inventory)[slot].sprite
      if not item_sprite then return end

      local anchor_offset
      local entity_anchor = -Query(entity.sprite).anchor[slot]
      if item_sprite.anchor and entity_anchor then
        anchor_offset = (entity_anchor - item_sprite.anchor) * scale
      else
        anchor_offset = Vector.zero
      end
      local wx, wy = unpack(offset_position + anchor_offset)
      love.graphics.draw(item_sprite.image, wx, wy, 0, scale)
    end

    local is_main_hand_in_background = entity.direction == "up"
    local is_other_hand_in_background = entity.direction ~= "down"
    if is_main_hand_in_background then display_slot("main_hand") end
    if is_other_hand_in_background then display_slot("other_hand") end

    local x, y = unpack(offset_position)
    Query(State.shader):preprocess(entity)
    if entity.sprite.quad then
      love.graphics.draw(entity.sprite.image, entity.sprite.quad, x, y, 0, scale)
    else
      love.graphics.draw(entity.sprite.image, x, y, 0, scale)
    end

    display_slot("hurt")
    display_slot("gloves")
    if not is_main_hand_in_background then display_slot("main_hand") end
    if not is_other_hand_in_background then display_slot("other_hand") end
  end,

  postProcess = function(self)
    if State.gui.show_fps then
      love.graphics.print("FPS: %.2f" % (1 / love.timer.getAverageDelta()), default_font, 5, 5)
    end
    local mode = State:get_mode()
    if mode == "text_input" then return State.gui.text_input:display() end
    if mode == "death" then return self:_display_death_message() end
    self:_display_hint()
    if Table.contains({"reading"}, mode) or State.shader or State.gui.disable_ui then return end
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
    self:_process_image_sprite(
      State.player,
      (Vector({love.graphics.getDimensions()})
      - Vector({State.player.sprite.image:getDimensions()}) * scale) / 2
      + Vector.up * 400,
      scale
    )

    local heading_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 72)
    local subheading_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 24)
    draw_centered("Game over", heading_font, 0, 0)
    draw_centered("[Enter] чтобы начать с последнего сохранения", subheading_font, 0, 80)
    draw_centered("[R] чтобы начать игру заново", subheading_font, 0, 110)
  end,

  _display_text_info = function(self)
    love.graphics.printf(
      State.gui.sidebar:get_text(), default_font,
      love.graphics.getWidth() - State.gui.sidebar.W, 300,
      State.gui.sidebar.W - 15
    )
  end,

  _display_hint = function(self)
    local content = State.gui.sidebar:get_hint()
    local x = (love.graphics.getWidth() - hint_font:getWidth(content)) / 2
    local y = love.graphics.getHeight() - hint_font:getHeight() - 50

    love.graphics.setColor(Colors.black)
    love.graphics.rectangle("fill", x, y, hint_font:getWidth(content), hint_font:getHeight())
    love.graphics.setColor(Colors.absolute_white)
    love.graphics.print({Colors.gray, content}, hint_font, x, y)
  end,
}))

return display
