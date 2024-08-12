local mech = require("mech")
local utf8 = require("utf8")
local races = require("mech.races")
local translation = require("tech.translation")
local perk_form = require("state.gui.character_creator.perk_form")
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

local len = function(str)
  str = str:gsub("&.t;", "&")
  Log.trace(str)
  return utf8.len(str)
end

local build_table = function(headers, matrix)
  local total_header = table.concat(headers, "  ")
  local header_sizes = Fun.range(#headers)
    :map(function(x)
      return math.max(len(headers[x]), Fun.range(#matrix)
        :map(function(y) return len(matrix[y][x]) end)
        :max())
    end)
    :totable()

  total_header = Fun.iter(headers)
    :enumerate()
    :map(function(x, h) return tostring(h) .. " " * (header_sizes[x] - len(h)) .. "  " end)
    :reduce(Fun.op.concat, "")

  local text = total_header .. "\n"
    .. "   " .. "-" * (Fun.iter(header_sizes):sum() + 2 * #header_sizes - 3)

  for y, row in ipairs(matrix) do
    text = text .. "\n"
    for x, value in ipairs(row) do
      text = text .. tostring(value) .. " " * (header_sizes[x] - len(value) + 2)
    end
  end

  return text
end

return Module("state.gui.character_creator.forms", {
  race = function(params)
    local text = "%s  <h2>Раса: &lt; %s &gt;</h2>" % {
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
      text = text .. "   Бонус +1 ко всем способностям\n"
    else
      Fun.iter(races[params.race].bonuses):enumerate():each(function(i, size)
        local j = i + params.max_index
        text = text .. ("%s  Бонус +%s: &lt; %s &gt;\n" % {
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
    local text = "   <h2>Способности</h2>"
      .. "   Свободные очки: %s\n\n" % params.points

    local bonus_column = Fun.iter(mech.abilities_list)
      :map(function(a)
        local bonus_i = Tablex.index_of(params.bonuses, a)
        return a, (bonus_i and races[params.race].bonuses[bonus_i] or 0)
      end)
      :tomap()

    params.abilities_final = Fun.iter(params.abilities_raw)
      :map(function(a, v) return a, v + bonus_column[a] end)
      :tomap()

    text = text
      .. build_table(
        {" ", "Способность ", "Значение", "Бонус расы", "Результат", "Модификатор"},
        Fun.iter(mech.abilities_list)
          :enumerate()
          :map(function(i, a)
            return {
              params:_get_indicator(i + params.max_index),
              translation.ability[a],
              "%s %s %s" % {
                params.abilities_raw[a] > 8 and "&lt;" or " ",
                tostring(params.abilities_raw[a]):rjust(2, "0"),
                params.abilities_raw[a] < 15
                  and params.points >= cost[
                    params.abilities_raw[a] + 1] - cost[params.abilities_raw[a]
                  ]
                  and "&gt;" or " ",
              },
              "%+i" % bonus_column[a],
              "= " .. params.abilities_final[a],
              "%+i" % mech.get_modifier(params.abilities_final[a])
            }
          end)
          :totable()
      )

    for i, a in ipairs(mech.abilities_list) do
      params.movement_functions[i + params.max_index] = function(dx)
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
    end

    params.max_index = params.max_index + 6
    return text .. "\n\n\n"
  end,

  skills = function(params)
    local text = "   <h2>Навыки</h2>"
      .. "   Свободные навыки: %s\n\n" % params.free_skills

    local bonus_column = Fun.iter(mech.skill_bases)
      :map(function(s, a) return s, mech.get_modifier(params.abilities_final[a]) end)
      :tomap()

    local result_column = Fun.iter(bonus_column)
      :map(function(s, m) return s, (params.skills[s] and 2 or 0) + m end)
      :tomap()

    text = text
      .. build_table(
        {" ", "Навык ", "Владение", "Бонус", "Результат"},
        Fun.iter(mech.skills)
          :enumerate()
          :map(function(i, s)
            return {
              params:_get_indicator(i + params.max_index),
              translation.skill[s],
              params.skills[s] and "x" or " ",
              "%+i" % bonus_column[s],
              "= %+i" % result_column[s],
            }
          end)
          :totable()
      )

    for i, s in ipairs(mech.skills) do
      params.movement_functions[i + params.max_index] = function(dx)
        if params.skills[s] then
          params.skills[s] = nil
          params.free_skills = params.free_skills + 1
          return
        end
        if params.free_skills <= 0 then return end
        params.free_skills = params.free_skills - 1
        params.skills[s] = true
      end
    end

    params.max_index = params.max_index + #mech.skills
    return text .. "\n\n\n"
  end,

  class = function(params)
    return "   <h2>Класс: %s</h2>" % translation.class[params.class.codename]
      .. Fun.iter(class.get_choices(params.class.progression_table, params.level))
        :map(function(choice) return perk_form(choice, params) end)
        :reduce(Fun.op.concat, "")
  end,
})
