local common = require("utils.common")


local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

return Tiny.system({
  base_callback = "draw",

  update = function(_, state)
    local max = state.player:get_turn_resources()

    local lines = {
      "HP: " .. state.player.hp .. "/?",
      "",
      "Resources:",
      "  Movement: " .. state.player.turn_resources.movement .. "/" .. max.movement,
      "  Actions: " .. state.player.turn_resources.actions .. "/" .. max.actions,
      "  Bonus actions: " .. state.player.turn_resources.bonus_actions .. "/" .. max.bonus_actions,
      "  Reactions: " .. state.player.turn_resources.reactions .. "/" .. max.reactions,
    }

    if state.move_order then
      common.concat(lines, {
        "",
        "Move order:",
      })

      common.concat(lines, Fun.iter(state.move_order.list)
        :enumerate()
        :map(function(i, e) return (state.move_order.current_i == i and "x " or "- ") .. (e.name or "_") end)
        :totable()
      )
    end

    for i, line in ipairs(lines) do
      love.graphics.print(line, ui_font, 600, i * 15)
    end
  end,
})
