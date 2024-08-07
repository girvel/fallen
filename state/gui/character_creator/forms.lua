local mech = require("mech")
local utf8 = require("utf8")
local races = require("mech.races")
local translation = require("tech.translation")
local perk_form = require("state.gui.character_creator.perk_form")
local fighter = require("mech.classes.fighter")
local feats = require("mech.feats")
local class = require("mech.class")


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

return Module("state.gui.character_creator.forms", {
  race = function(params)
    local text = "%s # Раса: < %s >\n\n" % {
        params:_get_indicator(params.max_index + 1),
        translation.race[params.race]
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
        text = text .. ("%s Бонус +%s: < %s >\n" % {
          params:_get_indicator(j),
          size,
          translation.ability[params.bonuses[i]],
          42,
        })

        params.movement_functions[j] = function(dx)
          local list = Fun.iter(mech.abilities_list)
            :filter(function(a)
              return not Tablex.contains(params.bonuses, a)
              or a == params.bonuses[i]
            end)
            :totable()
          params.bonuses[i] = list[(Tablex.index_of(list, params.bonuses[i]) + dx - 1) % #list + 1]
        end
      end)
      params.max_index = params.max_index + #races[params.race].bonuses
    end

    if races[params.race].feat_flag then
      text = text .. "\n" .. perk_form(feats.perk, params)
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
        translation.ability[a]:ljust(utf8.len(headers[1]), " "),
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

  class = function(params)
    return "  # Класс: воин\n\n"
      .. Fun.iter(class.get_choices(fighter.progression_table, 2))
        :map(function(choice) return perk_form(choice, params) end)
        :reduce(Fun.op.concat, "")
  end,
})
