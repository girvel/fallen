local interactive = require("tech.interactive")
local level = require("tech.level")


local ui_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12)

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

return Tiny.sortedProcessingSystem({
  filter = Tiny.requireAll("position", "sprite", "view"),
  base_callback = "draw",

  SIDEBAR_W = 300,
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
    if State.gui.text_entities then
      love.graphics.clear()
      return
    end

    if State.player.hears then
      return self:display_line(State.player.hears)
    end

    self:_display_text_info()
    self:_update_views()
  end,

  _update_views = function(self)
    for key, value in pairs({
      wiki = ((Vector({love.graphics.getDimensions()}) - State.gui.TEXT_MAX_SIZE) / 2):ceil(),
      actions = Vector({love.graphics.getWidth() - self.SIDEBAR_W, 15}),
      scene_fx = get_scene_offset(),
      scene = get_scene_offset(),
    }) do
      State.gui.views[key].offset = value
    end
  end,

  process = function(self, entity)
    local current_view = State.gui.views[entity.view]
    local x, y = unpack(current_view:apply(entity.position))
    if entity.sprite.text then
      local display = entity.link
        and {State.gui.LINK_COLOR, entity.sprite.text}
        or entity.sprite.text

      love.graphics.print(display, entity.sprite.font, x, y)
    else
      local display_main_hand = function()
        local weapon_sprite = -Query(entity.inventory).main_hand.sprite
        if weapon_sprite and weapon_sprite.anchor and entity.sprite.anchor then
          local wx, wy = unpack(Vector({x, y}) + (entity.sprite.anchor - weapon_sprite.anchor) * current_view.scale)
          love.graphics.draw(weapon_sprite.image, wx, wy, 0, current_view.scale)
        end
      end

      local is_weapon_in_background = entity.direction == "up"
      if is_weapon_in_background then display_main_hand() end

      love.graphics.draw(entity.sprite.image, x, y, 0, current_view.scale)

      if not is_weapon_in_background then display_main_hand() end
    end
  end,

  display_line = function(self, line)
    local window_w = love.graphics.getWidth()
    local window_h = love.graphics.getHeight()
    local text_w = math.min(window_w - 40, State.gui.TEXT_MAX_SIZE[1])

    love.graphics.setColor(Common.hex_color("31222c"))
    love.graphics.rectangle("fill", 0, window_h - 140, window_w, 140)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(line, ui_font, math.ceil((window_w - text_w) / 2), window_h - 120, text_w)
  end,

  _display_text_info = function(self)
    local max = State.player:get_turn_resources()

    local lines = {
      "Здоровье: " .. State.player.hp .. "/" .. State.player:get_max_hp(),
    }

    local weapon = State.player.inventory.main_hand
    if weapon then
      Tablex.concat(lines, {
        "",
        "Оружие: " .. weapon.name .. " (" .. weapon.damage_roll:to_string() .. ")",
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
        "Нажмите [E] чтобы взаимодействовать с " .. potential_interaction.name,
      })
    end

    love.graphics.printf(
      table.concat(lines, "\n"), ui_font,
      love.graphics.getWidth() - self.SIDEBAR_W, 15 + 400,
      self.SIDEBAR_W - 15
    )
  end,
})
