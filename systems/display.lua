local level = require("tech.level")
local tech_constants = require("tech.constants")


local get_scene_offset = function()
  if not State.player then return Vector.zero end
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local border_w = math.floor(window_w / 3)
  local border_h = math.floor(window_h / 3)
  local player_x, player_y = unpack(State.player.position * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)
  local grid_w, grid_h = unpack(State.grids.solids.size * tech_constants.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)

  local result = -Vector({
    Mathx.median(
      0,
      player_x - window_w + border_w,
      -State.gui.views.scene_fx.offset[1],
      player_x - border_w,
      grid_w - window_w
    ),
    Mathx.median(
      0,
      player_y - window_h + border_h,
      -State.gui.views.scene_fx.offset[2],
      player_y - border_h,
      grid_h - window_h
    )
  })

  return result
end

local get_dialogue_offset = function()
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local text_w = math.min(window_w - 40, State.gui.TEXT_MAX_SIZE[1])

  return Vector({math.ceil((window_w - text_w) / 2), window_h - 130})
end

local get_full_screen_text_offset = function()
  return ((Vector({love.graphics.getDimensions()}) - State.gui.TEXT_MAX_SIZE) / 2):ceil()
end

return Tiny.sortedProcessingSystem({
  codename = "display",
  filter = Tiny.requireAll("position", "sprite", "view"),
  base_callback = "draw",

  _old_camera_position = Vector.zero,

  _unknown_icon = love.graphics.newImage("assets/sprites/icons/unknown.png"),

  compare = function(self, first, second)
    if first.view ~= second.view then
      local iterator = Fun.iter(State.gui.views_order):enumerate()
      return (
        select(1, iterator:filter(function(i, name) return name == first.view end):nth(1))
        < select(1, iterator:filter(function(i, name) return name == second.view end):nth(1))
      )
    end

    if not first.layer or first.layer == second.layer then return end

    local iterator = Fun.iter(level.GRID_LAYERS):enumerate()
    return (
      select(1, iterator:filter(function(i, name) return name == first.layer end):nth(1))
      < select(1, iterator:filter(function(i, name) return name == second.layer end):nth(1))
    )
  end,

  preProcess = function(self)
    self:_update_views()
    State.gui.sidebar:update_indicators()
  end,

  _update_views = function(self)  -- TODO move to State.gui
    for key, value in pairs({
      scene_fx = get_scene_offset(),
      scene = get_scene_offset(),
      actions = Vector({love.graphics.getWidth() - State.gui.sidebar.W + 16, 64 + 15}),
      sidebar_background = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
      sidebar = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
      sidebar_text = Vector({love.graphics.getWidth() - State.gui.sidebar.W, 0}),
      dialogue_background = Vector.zero,
      dialogue_text = get_dialogue_offset(),
      wiki = get_full_screen_text_offset(),
      character_creator = get_full_screen_text_offset(),
    }) do
      State.gui.views[key].offset = value
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
    love.graphics.print(entity.sprite.text, entity.sprite.font, unpack(offset_position))

    if entity.link_flag then
      local start = offset_position + Vector.down * entity.size[2]
      local finish = offset_position + entity.size  -- TODO here size is outside the view, for mousepressed it is inside
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
      if item_sprite.anchor and entity.sprite.anchor then
        anchor_offset = (entity.sprite.anchor[slot] - item_sprite.anchor) * scale
      else
        anchor_offset = Vector.zero
      end
      local wx, wy = unpack(offset_position + anchor_offset)
      love.graphics.draw(item_sprite.image, wx, wy, 0, scale)
    end

    local is_weapon_in_background = entity.direction == "up"
    if is_weapon_in_background then display_slot("main_hand") end

    local x, y = unpack(offset_position)
    if entity.sprite.quad then
      love.graphics.draw(entity.sprite.image, entity.sprite.quad, x, y, 0, scale)
    else
      love.graphics.draw(entity.sprite.image, x, y, 0, scale)
    end

    display_slot("gloves")
    if not is_weapon_in_background then display_slot("main_hand") end
  end,

  postProcess = function(self)
    local mode = State:get_mode()
    if Tablex.contains({"reading"}, mode) then return end
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
