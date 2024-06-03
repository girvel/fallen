local common = require("utils.common")


local ui_font = love.graphics.newFont("assets/fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 12)

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
        "Resources:",
      },
      Fun.iter(state.player.turn_resources)
        :map(function(k, v) return "  " .. k .. ": " .. tostring(v) .. "/" .. tostring(max[k]) end)
        :totable()
    )

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

  display_text = function(text)
    local w = love.graphics.getWidth()

    love.graphics.clear()
    love.graphics.printf(text, ui_font, 20, 20, w - 40)
  end,
})
