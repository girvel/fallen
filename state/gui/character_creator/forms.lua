local utf8 = require("utf8")
local abilities = require("mech.abilities")
local races = require("mech.races")
local translation = require("tech.translation")
local perk_form = require("state.gui.character_creator.perk_form")
local feats = require("mech.feats")
local class = require("mech.class")


local forms, module_mt, static = Module("state.gui.character_creator.forms")

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

forms.race = static(function(params)
  local text = "%s  <h2>Раса: &lt; %s &gt;</h2>" % {
      params:_get_indicator(params.max_index + 1),
      translation.race[params.race]
    }

  params.movement_functions[params.max_index + 1] = function(dx)
    params.race = available_races[
      (Table.index_of(available_races, params.race) + dx - 1) % #available_races + 1
    ]
  end

  params.max_index = params.max_index + 1

  params.bonuses = Fun.iter(params.bonuses)
    :take_n(math.min(#params.bonuses, #races[params.race].bonuses))
    :totable()

  params.bonuses = Fun.iter(params.bonuses)
    :chain(Fun.iter(abilities.list)
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
        translation.abilities[params.bonuses[i]],
        42,
      })

      params.movement_functions[j] = function(dx)
        local list = Fun.iter(abilities.list)
          :filter(function(a)
            return not Table.contains(params.bonuses, a)
            or a == params.bonuses[i]
          end)
          :totable()
        params.bonuses[i] = list[(Table.index_of(list, params.bonuses[i]) + dx - 1) % #list + 1]
      end
    end)
    params.max_index = params.max_index + #races[params.race].bonuses
  end

  if races[params.race].feat_flag then
    text = text .. "\n" .. perk_form(feats.perk, params)
  end

  return text .. "\n\n"
end)

forms.abilities = static(function(params)
  local text = "   <h2>Характеристики</h2>"
    .. "   Свободные очки: %s\n\n" % params.points

  local bonus_column = Fun.iter(abilities.list)
    :map(function(a)
      local bonus_i = Table.index_of(params.bonuses, a)
      return a, (bonus_i and races[params.race].bonuses[bonus_i] or 0)
    end)
    :tomap()

  params.abilities_final = Fun.iter(params.abilities_raw)
    :map(function(a, v) return a, v + bonus_column[a] end)
    :tomap()

  text = text
    .. Common.build_table(
      {" ", "Способность ", "Значение", "Бонус расы", "Результат", "Модификатор"},
      Fun.iter(abilities.list)
        :enumerate()
        :map(function(i, a)
          return {
            params:_get_indicator(i + params.max_index),
            translation.abilities[a],
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
            "%+i" % abilities.get_modifier(params.abilities_final[a])
          }
        end)
        :totable(),
      true
    )

  for i, a in ipairs(abilities.list) do
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
end)

forms.skills = static(function(params)
  local text = "   <h2>Навыки</h2>"
    .. "   Свободные навыки: %s\n\n" % params.free_skills

  local base_column = Fun.iter(abilities.skill_bases)
    :map(function(s, a) return s, String.utf_sub(translation.abilities[a], 1, 3) end)
    :tomap()

  local bonus_column = Fun.iter(abilities.skill_bases)
    :map(function(s, a) return s, abilities.get_modifier(params.abilities_final[a]) end)
    :tomap()

  local result_column = Fun.iter(bonus_column)
    :map(function(s, m) return s, (params.skills[s] and 2 or 0) + m end)
    :tomap()

  text = text
    .. Common.build_table(
      {" ", "Навык ", "Владение", "База", "Бонус", "Результат"},
      Fun.iter(abilities.skills)
        :enumerate()
        :map(function(i, s)
          return {
            params:_get_indicator(i + params.max_index),
            translation.skill[s],
            params.skills[s] and "x" or " ",
            base_column[s],
            "%+i" % bonus_column[s],
            "= %+i" % result_column[s],
          }
        end)
        :totable(),
      true
    )

  for i, s in ipairs(abilities.skills) do
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

  params.max_index = params.max_index + #abilities.skills
  return text .. "\n\n\n"
end)

forms.class = static(function(params)
  return "   <h2>Класс: %s, уровень %s</h2>" % {translation.class[params.class.codename], params.level}
    .. Fun.iter(class.get_choices(params.class.progression_table, params.level))
      :map(function(choice) return perk_form(choice, params) end)
      :reduce(Fun.op.concat, "")
    .. "\n"
end)

return forms
