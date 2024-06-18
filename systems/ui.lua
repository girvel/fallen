local common = require("utils.common")
local interactive = require("tech.interactive")


local ui_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12)

local resource_translations = {
  bonus_actions = "бонусные действия",
  movement = "движение",
  reactions = "реакции",
  actions = "действия",
  has_advantage = "преимущество",
}

local value_translations = {
  [true] = "да",
  [false] = "нет",
}

return Tiny.system({
  base_callback = "draw",

  update = function(self, state)
    if state.player.reads then
      return self:display_text(state.player.reads)
    end

    if state.player.hears then
      return self:display_line(state.player.hears)
    end

    local max = state.player:get_turn_resources()

    local lines = common.concat(
      {
        "Здоровье: " .. state.player.hp .. "/" .. state.player:get_max_hp(),
        "",
        "Ресурсы:",
      },
      Fun.iter(state.player.turn_resources)
        :map(function(k, v)
          return (
            "  " .. (resource_translations[k] or k) ..
            ": " .. (value_translations[v] or tostring(v))
            .. "/" .. (value_translations[max[k]] or tostring(max[k]))
          )
        end)
        :totable()
    )

    if state.move_order then
      common.concat(lines, {
        "",
        "Очередь ходов:",
      })

      common.concat(lines, Fun.iter(state.move_order.list)
        :enumerate()
        :map(function(i, e) return (state.move_order.current_i == i and "x " or "- ") .. (e.name or "_") end)
        :totable()
      )

      common.concat(lines, {
        "",
        "Space - закончить ход",
      })
    end

    common.concat(lines, {
      "",
      "1 - атака рукой",
      "2 - ничего не делать",
      "3 - отравляющая тирада",
      "4 - прицелиться",
      "5 - мощная атака",
      "z - рывок",
    })

    local potential_interaction = interactive.get_for(state.player, state)
    if potential_interaction then
      common.concat(lines, {
        "",
        "Нажмите [E] чтобы взаимодействовать с " .. potential_interaction.name,
      })
    end

    local WIDTH = 300
    love.graphics.printf(
      table.concat(lines, "\n"), ui_font,
      love.graphics.getWidth() - WIDTH, 15,
      WIDTH - 15
    )
  end,

  TEXT_MAX_W = 1000,
  TEXT_MAX_H = 800,

  display_text = function(self, text)
    local window_w = love.graphics.getWidth()
    local window_h = love.graphics.getHeight()
    local text_w = math.min(window_w - 40, self.TEXT_MAX_W)
    local text_h = math.min(window_h - 40, self.TEXT_MAX_H)

    love.graphics.clear()
    love.graphics.printf(
      text, ui_font,
      math.ceil((window_w - text_w) / 2), math.ceil((window_h - text_h) / 2),
      text_w
    )
  end,

  display_line = function(self, line)
    local window_w = love.graphics.getWidth()
    local window_h = love.graphics.getHeight()
    local text_w = math.min(window_w - 40, self.TEXT_MAX_W)

    love.graphics.setColor(common.hex_color("31222c"))
    love.graphics.rectangle("fill", 0, window_h - 140, window_w, 140)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(line, ui_font, math.ceil((window_w - text_w) / 2), window_h - 120, text_w)
  end,
})
