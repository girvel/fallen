local interactive = require("tech.interactive")
local view = require("utils.view")


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

return Tiny.processingSystem({
  filter = Tiny.requireAll("gui_position", "sprite"),
  base_callback = "draw",

  SIDEBAR_W = 300,

  _unknown_icon = love.graphics.newImage("assets/sprites/icons/unknown.png"),

  preProcess = function(self)
    if State.gui.text_entities then
      love.graphics.clear()
      return
    end

    if State.player.hears then
      return self:display_line(State.player.hears)
    end

    self:_display_text_info()

    State.gui.views = {
      wiki = view(
        ((Vector({love.graphics.getDimensions()}) - State.gui.TEXT_MAX_SIZE) / 2):ceil(),
        1
      ),
      actions = view(
        Vector({love.graphics.getWidth() - self.SIDEBAR_W, 15}),
        2
      ),
    }
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

  process = function(self, entity)
    local x, y = unpack(State.gui.views[entity.view]:apply(entity.gui_position))
    if entity.sprite.text then
      local display = entity.link
        and {State.gui.LINK_COLOR, entity.sprite.text}
        or entity.sprite.text

      love.graphics.print(display, entity.sprite.font, x, y)
    else
      love.graphics.draw(entity.sprite.image, x, y, 0, unpack(entity.scale or Vector.zero))
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
})
