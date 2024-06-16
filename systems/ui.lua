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
      return self.display_text(state.player.reads)
    end

    if state.player.hears then
      return self.display_line(state.player.hears)
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

  display_text = function(text)
    local w = love.graphics.getWidth()

    love.graphics.clear()
    love.graphics.printf(text, ui_font, 20, 20, w - 40)
  end,

  display_line = function(line)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    love.graphics.printf(line, ui_font, 20, h - 120, w - 40)
  end,
})
