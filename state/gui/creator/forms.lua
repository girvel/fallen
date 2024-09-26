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

forms.abilities = function()
  return Html.span {
    "   ",
    Html.h2 {"Характеристики"},
    Html.p {
      -- TODO Html().build_table(t)?
      Html().build_table(
        {
          {" ", "H1", "H2"},
          {" ", Html.tline {}},
          {" ", "One", "Two"},
          {" ", "Three", "Four"},
        }
      ),
      Html.table {
        Html.tr {Html.td {" "}, Html.tline {}},
        Html.tr {Html.td {" "}, Html.td {"One"}, Html.td {"Two"}},
        Html.tr {Html.td {" "}, Html.td {"Three"}, Html.td {"Four"}},
      },
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
          unpack(Fun.iter(perks)
            :filter(function(p) return not p.hidden end)
            :map(perk_form)
            :totable())
        }
      end)
      :totable()
  )
end

return forms
