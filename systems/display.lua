local level = require("tech.level")
local tcod = require("lib.tcod")
local ffi = require("ffi")


return Tiny.sortedProcessingSystem({
  codename = "display",
  -- filter = Tiny.requireAll("position", "sprite", "view"),
  -- TODO RM?
  filter = function(self, e) return e.position and e.sprite and e.view and e.view ~= "scene" end,
  base_callback = "draw",

  _fov_map = nil,

  compare = function(self, first, second)
    if first.view ~= second.view then
      local iterator = Fun.iter(State.gui.views_order):enumerate()
      return (
        select(1, iterator:filter(function(i, name) return name == first.view end):nth(1))
        < select(1, iterator:filter(function(i, name) return name == second.view end):nth(1))
      )
    end

    -- if not first.layer or first.layer == second.layer then return end

    -- local iterator = Fun.iter(level.GRID_LAYERS):enumerate()
    -- return (
    --   select(1, iterator:filter(function(i, name) return name == first.layer end):nth(1))
    --   < select(1, iterator:filter(function(i, name) return name == second.layer end):nth(1))
    -- )
    -- TODO RM
  end,

  preProcess = function(self, event)
    State.gui:update_views()
    State.gui.sidebar:update_indicators(event[1])

    self:process_grid(event)
  end,

  process_grid = function(self, event)
    if Tablex.contains({"character_creator", "reading", "death"}, State:get_mode()) then return end

    -- borders --
    local view = State.gui.views.scene
    local start = view:inverse_multipler(-view.offset):map(math.floor)
    local finish = start + view:inverse_multipler(Vector({love.graphics.getDimensions()})):map(math.ceil)

    start = Vector.use(Mathx.median, Vector.one, start, State.grids.solids.size)
    finish = Vector.use(Mathx.median, Vector.one, finish, State.grids.solids.size)

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
        local e = solids:fast_get(x, y)
        tcod.TCOD_map_set_properties(self._fov_map, x, y, bool(not e or e.transparent_flag), not e)
      end
    end

    local px, py = unpack(State.player.position)
    tcod.TCOD_map_compute_fov(self._fov_map, px, py, 20, true, ffi.C.FOV_PERMISSIVE_8)

    for _, layer in ipairs(level.GRID_LAYERS) do
      local grid = State.grids[layer]
      for x = start[1], finish[1] do
        for y = start[2], finish[2] do
          if tcod.TCOD_map_is_in_fov(self._fov_map, x, y) then
            local e = grid:fast_get(x, y)
            if e then self:process(e) end
          end
        end
      end
    end
  end,

  process = function(self, entity)
    local mode = State:get_mode()
    if
      mode == "character_creator" and entity.view ~= "character_creator"
      or mode == "reading" and entity.view ~= "wiki"
      or mode == "death"
    then return end

    local current_view = State.gui.views[entity.view]
    local offset_position = current_view:apply(entity.position)
    if entity.sprite.text then
      self:_process_text_sprite(entity, offset_position)
    elseif entity.sprite.image then
      self:_process_image_sprite(entity, offset_position, current_view.scale)
    elseif entity.sprite.rect_color then
      local x, y = unpack(offset_position)
      love.graphics.setColor(entity.sprite.rect_color)
      love.graphics.rectangle("fill", x, y, unpack(current_view:apply_multiplier(entity.size)))
      love.graphics.setColor({1, 1, 1})
    else
      error("Wrong sprite format of %s:\n%s" % {Common.get_name(entity), Inspect(entity.sprite)})
    end
  end,

  _process_text_sprite = function(self, entity, offset_position)
    if State.shader then return end
    love.graphics.print(entity.sprite.text, entity.sprite.font, unpack(offset_position))

    if entity.link_flag then
      local view = State.gui.views[entity.view]
      local start = offset_position + Vector.down * entity.size[2]
      local finish = offset_position + view:apply_multiplier(entity.size)
      local mouse_position = Vector({love.mouse.getPosition()})
      if not (mouse_position >= offset_position and mouse_position < finish) then return end

      if type(entity.sprite.text) == "table" then
        love.graphics.setColor(entity.sprite.text[1])
      end
      love.graphics.line(start[1], start[2], unpack(finish))
      love.graphics.setColor({1, 1, 1})
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
      love.graphics.print("FPS: %.2f" % (1 / love.timer.getAverageDelta()), State.gui.font, 5, 5)
    end
    local mode = State:get_mode()
    if Tablex.contains({"reading"}, mode) or State.shader then return end
    if mode == "death" then return self:_display_death_message() end
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
    draw_centered("Press [Enter] to restart", subheading_font, 0, 80)
  end,

  _display_text_info = function(self)
    love.graphics.printf(
      State.gui.sidebar:get_text(), State.gui.font,
      love.graphics.getWidth() - State.gui.sidebar.W, 115,
      State.gui.sidebar.W - 15
    )
  end,
})
