local wrapping = require("tech.stateful.gui.wrapping")
local mech = require("mech")
local utf8 = require("utf8")
local player = require("library.player")  -- TODO move to tech


local ability_translations = {  -- TODO translation module
  strength = "сила",
  dexterity = "ловкость",
  constitution = "телосложение",
  intelligence = "интеллект",
  wisdom = "мудрость",
  charisma = "харизма",
}

local cost = {
  [8] = 0,
  [9] = 1,
  [10] = 2,
  [11] = 3,
  [12] = 4,
  [13] = 5,
  [14] = 7,
  [15] = 9,
}

local available_races = {"human", "variant_human_1", "variant_human_2"}
local race_translations = {
  human = "Человек",
  variant_human_1 = "Человек (вариант) +1/+1",
  variant_human_2 = "Человек (вариант) +2",
}

return function()
  return {
    player_anchor = nil,
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
      current_index = 1,
      max_index = 1,
      movement_functions = {},
      race = "human",
    },

    refresh = function(self)
      local params = self.parameters
      if self.text_entities then
        State:remove_multiple(self.text_entities)
      end

      if State.player then
        self.text_entities = nil
        return
      end

      params.movement_functions = {}
      local text = ""

      -- TODO split to functions
      text = text
        .. "  # Раса\n\n"
        .. "%s < %s >\n\n" % {
          params.current_index == 1 and ">" or " ",
          race_translations[params.race]
        }

      params.movement_functions[1] = function(dx)
        params.race = available_races[
          (Tablex.index_of(available_races, params.race) + dx - 1) % #available_races + 1
        ]
      end

      local index_offset = 1

      local headers = {"Способность ", "Значение", "Бонус расы", "   Результат", "Модификатор"}
      local total_header = table.concat(headers, "  ")

      text = text
        .. "  # Способности\n\n"
        .. "  Свободные очки: %s\n\n" % params.points
        .. "  " .. total_header .. "\n"
        .. "  " .. "-" * (utf8.len(total_header))

      Fun.iter(mech.abilities_list):enumerate():each(function(i, a)
        i = i + index_offset
        text = text .. "\n%s %s  %s %s %s  %s  =  %s  %s" % {
          i == params.current_index and ">" or " ",
          ability_translations[a]:ljust(utf8.len(headers[1]), " "),
          params.abilities[a] > 8 and "<" or " ",
          tostring(params.abilities[a]):rjust(2, "0"),
          string.ljust(
            params.abilities[a] < 15
              and params.points >= cost[params.abilities[a] + 1] - cost[params.abilities[a]]
              and ">" or " ",
            utf8.len(headers[2]) - 5, " "
          ),
          ("0"):ljust(utf8.len(headers[3]), " "),
          tostring(params.abilities[a]):ljust(utf8.len(headers[4]) - 3, " "),
          mech.get_modifier(params.abilities[a])
        }

        params.movement_functions[i] = function(dx)
          local next_value = params.abilities[a] + dx
          if dx < 0 and params.abilities[a] <= 8
            or dx > 0 and (
              params.abilities[a] >= 15
              or params.points < cost[next_value] - cost[params.abilities[a]]
            )
          then return end

          params.points = params.points + cost[params.abilities[a]] - cost[next_value]
          params.abilities[a] = next_value
        end
      end)

      self.text_entities = State:add_multiple(wrapping.generate_page(
        text,
        self.font, math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator"
      ))

      params.max_index = 7
    end,

    move_cursor = function(self, direction_name)
      assert(Tablex.contains(Vector.direction_names, direction_name))

      local params = self.parameters
      if direction_name == "down" then
        params.current_index = (params.current_index) % params.max_index + 1
      elseif direction_name == "up" then
        params.current_index = (params.current_index - 2) % params.max_index + 1
      else
        Query(params.movement_functions[params.current_index])(Vector[direction_name][1])
      end
      self:refresh()
    end,

    submit = function(self)
      local params = self.parameters
      if params.points > 0 then return end  -- TODO notification
      State.player = State:add(Tablex.extend(
        player(params.abilities),
        {position = self.player_anchor}
      ))
      Log.info("Created player")
      self:refresh()
    end,
  }
end
