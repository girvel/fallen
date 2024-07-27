local wrapping = require("tech.stateful.gui.wrapping")
local mech = require("mech")
local utf8 = require("utf8")
local player = require("library.player")  -- TODO move to tech
local races = require("mech.races")
local fighter = require("mech.classes.fighter")
local class = require("mech.class")


local ability_translations = {  -- TODO translation module
  strength = "сила",
  dexterity = "ловкость",
  constitution = "телосложение",
  intelligence = "интеллект",
  wisdom = "мудрость",
  charisma = "харизма",
}

local build_translations = {
  [fighter.fighting_style] = {
    two_handed_style = "бой двуручным оружием",
    duelist = "дуэлянт",
  }
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
      points = 0,
      abilities_raw = {
        strength = 15,
        dexterity = 15,
        constitution = 15,
        intelligence = 8,
        wisdom = 8,
        charisma = 8,
      },
      abilities_final = nil,
      current_index = 1,
      max_index = 1,
      movement_functions = {},
      race = "human",
      bonuses = {},

      build_options = {},

      _get_indicator = function(self, i)
        return i == self.current_index and ">" or " "
      end,
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
      params.max_index = 0
      local text = ""

      text = text
        .. self.forms.race(params)
        .. self.forms.abilities(params)

      for _, choice in ipairs(Fun.iter(fighter.progression_table)
        :take_n(2)  -- TODO level-dependent
        :map(function(perks)
          return Fun.iter(perks)
            :filter(function(perk) return perk.enum_variant == class.perk.choice end)
            :totable()
        end)
        :reduce(Tablex.concat, {}))
      do
        if not params.build_options[choice] then
          params.build_options[choice] = 1
        end
        text = text .. self.forms[choice](params)
      end

      self.text_entities = State:add_multiple(wrapping.generate_page(
        text,
        self.font, math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator"
      ))
    end,

    forms = {
      race = function(params)
        local text = "  # Раса\n\n"
          .. "%s < %s >\n\n" % {
            params:_get_indicator(params.max_index + 1),
            race_translations[params.race]
          }

        params.movement_functions[params.max_index + 1] = function(dx)
          params.race = available_races[
            (Tablex.index_of(available_races, params.race) + dx - 1) % #available_races + 1
          ]
        end

        params.max_index = params.max_index + 1

        params.bonuses = Fun.iter(params.bonuses)
          :take_n(math.min(#params.bonuses, #races[params.race].bonuses))
          :totable()

        params.bonuses = Fun.iter(params.bonuses)
          :chain(Fun.iter(mech.abilities_list)
            :filter(function(a) return Fun.iter(params.bonuses):all(function(b) return a ~= b end) end)
            :take_n(#races[params.race].bonuses - #params.bonuses)
          )
          :totable()

        if #params.bonuses == 6 then
          text = text .. "  Бонус +1 ко всем способностям\n"
        else
          Fun.iter(races[params.race].bonuses):enumerate():each(function(i, size)
            local j = i + params.max_index
            text = text .. ("%s Бонус +%s: %s\n" % {
              params:_get_indicator(j),
              size,
              ability_translations[params.bonuses[i]],
              42,
            })

            params.movement_functions[j] = function(dx)

            end
          end)
          params.max_index = params.max_index + #races[params.race].bonuses
        end

        return text .. "\n\n"
      end,

      abilities = function(params)
        local text = ""
        local headers = {"Способность ", "Значение", "Бонус расы", "   Результат", "Модификатор"}
        local total_header = table.concat(headers, "  ")

        text = text
          .. "  # Способности\n\n"
          .. "  Свободные очки: %s\n\n" % params.points
          .. "  " .. total_header .. "\n"
          .. "  " .. "-" * (utf8.len(total_header))

        local bonus_column = Fun.iter(mech.abilities_list)
          :map(function(a)
            local bonus_i = Tablex.index_of(params.bonuses, a)
            return a, (bonus_i and races[params.race].bonuses[bonus_i] or 0)
          end)
          :tomap()

        params.abilities_final = Fun.iter(params.abilities_raw)
          :map(function(a, v) return a, v + bonus_column[a] end)
          :tomap()

        Fun.iter(mech.abilities_list):enumerate():each(function(i, a)
          i = i + params.max_index
          text = text .. "\n%s %s  %s %s %s  %s  =  %s  %s" % {
            params:_get_indicator(i),
            ability_translations[a]:ljust(utf8.len(headers[1]), " "),
            params.abilities_raw[a] > 8 and "<" or " ",
            tostring(params.abilities_raw[a]):rjust(2, "0"),
            string.ljust(
              params.abilities_raw[a] < 15
                and params.points >= cost[
                  params.abilities_raw[a] + 1] - cost[params.abilities_raw[a]
                ]
                and ">" or " ",
              utf8.len(headers[2]) - 5, " "
            ),
            ("+" .. bonus_column[a]):ljust(utf8.len(headers[3]), " "),
            tostring(params.abilities_final[a]):ljust(utf8.len(headers[4]) - 3, " "),
            mech.get_modifier(params.abilities_final[a])
          }

          params.movement_functions[i] = function(dx)
            local next_value = params.abilities_raw[a] + dx
            if dx < 0 and params.abilities_raw[a] <= 8
              or dx > 0 and (
                params.abilities_raw[a] >= 15
                or params.points < cost[next_value] - cost[params.abilities_raw[a]]
              )
            then return end

            params.points = params.points + cost[params.abilities_raw[a]] - cost[next_value]
            params.abilities_raw[a] = next_value
          end
        end)

        params.max_index = params.max_index + 6
        return text .. "\n\n\n"
      end,

      [fighter.fighting_style] = function(params)
        local chosen_style = fighter.fighting_style.options[
          params.build_options[fighter.fighting_style]
        ]
        local text = "%s < %s >\n\n" % {
          params:_get_indicator(params.max_index + 1),
          build_translations[fighter.fighting_style][chosen_style.codename],
        }

        params.max_index = params.max_index + 1
        return text
      end,
    },

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
        player(params.abilities_final, races[params.race], params.build_options),
        {position = self.player_anchor}
      ))
      Log.info("Created player")
      self:refresh()
    end,
  }
end
