local wrapping = require("tech.stateful.gui.wrapping")
local mech = require("mech")
local utf8 = require("utf8")


local ability_translations = {
  strength = "сила",
  dexterity = "ловкость",
  constitution = "телосложение",
  intelligence = "интеллект",
  wisdom = "мудрость",
  charisma = "харизма",
}

return function()
  return {
    text_entities = nil,
    font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 18),

    parameters = {
      points = 27,
      abilities = {
        strength = 8,
        dexterity = 8,
        constitution = 8,
        intelligence = 8,
        wisdom = 8,
        charisma = 8,
      },
    },

    refresh = function(self)
      if self.text_entities then
        State:remove_multiple(self.text_entities)
      end

      local headers = {"Способность ", "Значение", "Бонус расы", "   Результат", "Модификатор"}
      -- local text = table.concat({
      --   "  Способность  Значение  Бонус расы     Результат  Модификатор",
      --   "  ------------------------------------------------------------",
      --   "  Сила         < 8 >     +0          =  9          -1",
      -- }, "\n")

      local text = "  " .. table.concat(headers, "  ") .. "\n"
      text = text
        .. "  " .. "-" * (utf8.len(text) - 3) .. "\n"
        .. table.concat(Fun.iter(mech.abilities_list)
          :map(function(a)
            return "  %s  %s %s %s  %s  =  %s  %s" % {
              ability_translations[a]:ljust(utf8.len(headers[1]), " "),
              self.parameters.abilities[a] > 8 and "<" or " ",
              tostring(self.parameters.abilities[a]):rjust(2, "0"),
              (self.parameters.abilities[a] < 15 and ">" or " "):ljust(utf8.len(headers[2]) - 5, " "),
              ("0"):ljust(utf8.len(headers[3]), " "),
              tostring(self.parameters.abilities[a]):ljust(utf8.len(headers[4]) - 3, " "),
              mech.get_modifier(self.parameters.abilities[a])
            }
          end)
          :totable(), "\n")

      self.text_entities = State:add_multiple(wrapping.generate_page(
        text,
        self.font, math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator"
      ))
    end,
  }
end
