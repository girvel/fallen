local interactive = require("tech.interactive")
local level = require("tech.level")


local resource_translations = {
  bonus_actions = "бонусные действия",
  movement = "движение",
  reactions = "реакции",
  actions = "действия",
  has_advantage = "преимущество",
  second_wind = "второе дыхание",
  action_surge = "всплеск действий",
}

local value_translations = {
  [true] = "да",
  [false] = "нет",
}

local last_offset
local get_scene_offset = function()
  local window_w = love.graphics.getWidth()
  local window_h = love.graphics.getHeight()
  local border_w = math.floor(window_w / 3)
  local border_h = math.floor(window_h / 3)
  local player_x, player_y = unpack(State.player.position * State.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)
  local grid_w, grid_h = unpack(State.grids.solids.size * State.CELL_DISPLAY_SIZE * State.SCALING_FACTOR)

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

  return Vector({math.ceil((window_w - text_w) / 2), window_h - 120})
end

return Tiny.sortedProcessingSystem({
  codename = "display",
  filter = Tiny.requireAll("position", "sprite", "view"),
  base_callback = "draw",

  SIDEBAR_W = 256,
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
    self:_update_indicators()
  end,

  _update_views = function(self)
    for key, value in pairs({
      scene_fx = get_scene_offset(),
      scene = get_scene_offset(),
      actions = Vector({love.graphics.getWidth() - self.SIDEBAR_W + 16, 64 + 15}),
      gui_background = Vector({love.graphics.getWidth() - self.SIDEBAR_W, 0}),
      gui = Vector({love.graphics.getWidth() - self.SIDEBAR_W, 0}),
      gui_text = Vector({love.graphics.getWidth() - self.SIDEBAR_W, 0}),
      dialogue_text = get_dialogue_offset(),
      wiki = ((Vector({love.graphics.getDimensions()}) - State.gui.TEXT_MAX_SIZE) / 2):ceil(),
    }) do
      State.gui.views[key].offset = value
    end
  end,

  _update_indicators = function(self)
    local text = "%s/%s" % {State.player.hp, State.player:get_max_hp()}
    local hp_text = State.gui.hp_text
    local font = hp_text.sprite.font

    hp_text.sprite.text = text
    hp_text.position = Vector({
      (self.SIDEBAR_W - font:getWidth(text)) / 2,
      32 - font:getHeight() / 2
    })

    local hp_bar = State.gui.hp_bar
    hp_bar.sprite.quad = love.graphics.newQuad(
      0, 0,
      hp_bar.sprite.image:getWidth() * State.player.hp / State.player:get_max_hp(),
      hp_bar.sprite.image:getHeight(),
      hp_bar.sprite.image:getDimensions()
    )
  end,

  process = function(self, entity)
    if State.player.hp <= 0 or State:get_mode() == "reading" and entity.view ~= "wiki" then return end

    local current_view = State.gui.views[entity.view]
    local offset_position = current_view:apply(entity.position)
    if entity.sprite.text then
      self:_process_text_sprite(entity, offset_position)
    else
      self:_process_image_sprite(entity, offset_position, current_view.scale)
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
    if State.player.hp <= 0 then return self:_display_death_message() end

    if State:get_mode() == "reading" then return end

    -- if State.player.hears then
    --   return self:display_line(State.player.hears)
    -- elseif State.player.dialogue_options then
    --   return self:display_line(Fun.iter(State.player.dialogue_options)
    --     :enumerate()
    --     :map(function(i, o)
    --       return "%s %s. %s\n" % {
    --         State.player.dialogue_options.current_i == i and ">" or " ", i, o
    --       }
    --     end)
    --     :reduce(Fun.op.concat, "")
    --   )
    -- end

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

  display_line = function(self, line)
    local window_w = love.graphics.getWidth()
    local window_h = love.graphics.getHeight()
    local text_w = math.min(window_w - 40, State.gui.TEXT_MAX_SIZE[1])

    love.graphics.setColor(Common.hex_color("31222c"))
    love.graphics.rectangle("fill", 0, window_h - 140, window_w, 140)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(line, State.gui.font, math.ceil((window_w - text_w) / 2), window_h - 120, text_w)
  end,

  _display_text_info = function(self)
    local max = State.player:get_turn_resources()

    local lines = {
      "Здоровье: " .. State.player.hp .. "/" .. State.player:get_max_hp(),
    }

    local weapon = State.player.inventory.main_hand
    if weapon then
      local roll = weapon.damage_roll:to_string()
      if weapon.bonus > 0 then
        roll = roll .. "+" .. weapon.bonus
      end
      Tablex.concat(lines, {
        "",
        "Оружие: " .. weapon.name .. " (" .. roll .. ")",
      })
    end

    Tablex.concat(
      lines,
      {"", "Ресурсы:"},
      Fun.iter(State.player.turn_resources)
        :map(function(k, v)
          return (
            "  " .. (resource_translations[k] or k) ..
            ": " .. (value_translations[v] or tostring(v)) ..
            (max[k] == nil and "" or "/" .. (value_translations[max[k]] or tostring(max[k])))
          )
        end)
        :totable()
    )

    if State.move_order then
      Tablex.concat(lines, {
        "",
        "Очередь ходов:",
      })

      Tablex.concat(lines, Fun.iter(State.move_order.list)
        :enumerate()
        :map(function(i, e) return (State.move_order.current_i == i and "x " or "- ") .. (e.name or "_") end)
        :totable()
      )

      Tablex.concat(lines, {
        "",
        "Space - закончить ход",
      })
    end

    -- Tablex.concat(lines, {
    --   "",
    --   "Действия:",
    --   "  1 - атака рукой",
    --   "  2 - ничего не делать",
    --   "  3 - второе дыхание",
    --   "  4 - всплеск действий",
    --   "  z - рывок",
    -- })

    local potential_interaction = interactive.get_for(State.player)
    if potential_interaction then
      Tablex.concat(lines, {
        "",
        "Нажмите [E] чтобы взаимодействовать с " .. Common.get_name(potential_interaction),
      })
    end

    love.graphics.printf(
      table.concat(lines, "\n"), State.gui.font,
      love.graphics.getWidth() - self.SIDEBAR_W, 15 + 400,
      self.SIDEBAR_W - 15
    )
  end,
})
