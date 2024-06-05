local common = require("utils.common")
local interactive = require("tech.interactive")


local ui_font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12)

return Tiny.system({
  base_callback = "draw",

  update = function(self, state)
    if state.player.reads then
      return self.display_text(state.player.reads)
    end

    local max = state.player:get_turn_resources()

    local lines = common.concat(
      {
        "HP: " .. state.player.hp .. "/" .. state.player:get_max_hp(),
        "",
        "Ресурсы:",
      },
      Fun.iter(state.player.turn_resources)
        :map(function(k, v) return "  " .. k .. ": " .. tostring(v) .. "/" .. tostring(max[k]) end)
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
        "Press [E] to interact with " .. potential_interaction.name,
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
})
