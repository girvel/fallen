local translation = require("tech.translation")
local abilities = require("mech.abilities")
local tags = require("state.gui.creator.tags")
local races = require("mech.races")
local perk_form = require("state.gui.creator.perk_form")


local forms, module_mt, static = Module("state.gui.creator.forms")

local progression_form

forms.class = static .. function()
  local mixin = State.gui.creator._mixin
  return Html.span {
    "   ",
    Html.h2 {"Класс: %s, уровень %s" % {mixin.class.name, mixin.level}},
    progression_form(mixin.class.progression_table),
  }
end

local allowed_races = {races.human, races.variant_human_1, races.variant_human_2}

forms.race = static .. function()
  local creator = State.gui.creator
  local mixin = creator._mixin
  local choices = creator._choices

  choices.race = choices.race or 1
  mixin.race = allowed_races[choices.race]

  table.insert(creator._movement_functions, function(dx)
    choices.race = (choices.race - 1 + dx) % #allowed_races + 1
    mixin.race = allowed_races[choices.race]
  end)
  local index = #creator._movement_functions

  local free_space = Fun.iter(allowed_races)
    :map(function(o) return o.name:utf_len() end)
    :max() - mixin.race.name:utf_len()
  local rjust = math.floor(free_space / 2)
  local ljust = free_space - rjust

  return Html.span {
    tags.anchor(index),
    "  ",
    Html.h2 {
      "Раса: ",
      tags.button(index, -1),
      " " * (1 + rjust),
      mixin.race.name,
      " " * (1 + ljust),
      tags.button(index, 1),
    },
    progression_form(mixin.race.progression_table),
  }
end

local ability_line

forms.abilities = function()
  local creator = State.gui.creator

  return Html.span {
    "   ", Html.h2 {"Характеристики"},
    Html.p {
      "   Свободные очки: ",
      Html.span {
        color = creator._ability_points == 0 and Colors.white() or Colors.red(),
        creator._ability_points,
      },
    },
    Html.p {
      Html().build_table(
        {
          {" ", "Способность ", "Значение", "Бонус расы", "Результат", "Модификатор"},
          {" ", Html.tline {}},
          Fun.iter(abilities.list)
            :map(ability_line)
            :unpack(),
        }
      ),
    }
  }
end


progression_form = function(progression_table)
  local mixin = State.gui.creator._mixin
  return Html.p(
    Fun.iter(progression_table)
      :take_n(mixin.level)
      :enumerate()
      :map(function(i, perks)
        return Html.span {
          color = i == mixin.level and Colors.green() or nil,
          Fun.iter(perks)
            :filter(function(p) return not p.hidden end)
            :map(perk_form)
            :unpack()
        }
      end)
      :totable()
  )
end

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

ability_line = function(ability_name)
  local creator = State.gui.creator

  table.insert(creator._movement_functions, function(dx)
    local this_value = creator._mixin.base_abilities[ability_name]
    local next_value = this_value + dx
    if dx < 0 and this_value <= 8
      or dx > 0 and (
        this_value >= 15
        or creator._ability_points < cost[next_value] - cost[this_value]
      )
    then return end

    creator._ability_points = creator._ability_points + cost[this_value] - cost[next_value]
    creator._mixin.base_abilities[ability_name] = next_value
  end)

  local index = #creator._movement_functions

  return {
    tags.anchor(index),
    translation.abilities[ability_name],
    Html.span {
      creator._mixin.base_abilities[ability_name] > 8
        and tags.button(index, -1)
        or " ",
      " ",
      tostring(creator._mixin.base_abilities[ability_name]):rjust(2, "0"),
      " ",
      creator._mixin.base_abilities[ability_name] < 15
        and tags.button(index, 1)
        or " ",
    },
    -- TODO! finish
    "?",
    "?",
    "?",
  }
end

return forms
