local class = require("mech.class")
local tags = require("state.gui.creator.tags")


local perk_form, module_mt, static = Module("state.gui.creator.perk_form")

local modifier_form

module_mt.__call = function(_, perk)
  local creator = State.gui.creator

  if perk.__type == class.choice then
    local choices = creator._choices
    choices[perk] = choices[perk] or 1
    local chosen_modifier = perk.options[choices[perk]]

    local free_space = Fun.iter(perk.options)
      :map(function(o) return o.name:utf_len() end)
      :max() - chosen_modifier.name:utf_len()
    local rjust = math.floor(free_space / 2)
    local ljust = free_space - rjust

    table.insert(creator._movement_functions, function(dx)
      choices[perk] = (choices[perk] - 1 + dx) % #perk.options + 1
    end)
    local index = #creator._movement_functions

    return Html.p {
      tags.anchor(index),
      Entity.name(perk),
      ": ",
      tags.button(index, -1),
      " " * (1 + rjust),
      modifier_form(chosen_modifier),
      " " * (1 + ljust),
      tags.button(index, 1),
    }
  end

  return Html.p {
    "   ",
    modifier_form(perk),
  }
end

modifier_form = function(perk)
  local get_tooltip
  local prefix = ""

  if perk.get_description then
    get_tooltip = Fn.curry(perk.get_description, perk, State.player)
  else
    local new_action = -Query(perk):modify_actions(State.player, {})[1]
    if new_action and new_action.get_description then
      get_tooltip = Fn.curry(new_action.get_description, new_action, State.player)
      prefix = "Новая способность: "
    end
  end

  return Html.span {
    get_tooltip = get_tooltip,
    prefix,
    Entity.name(perk),
  }
end

return perk_form
