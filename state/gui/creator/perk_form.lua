local class = require("mech.class")
local tags = require("state.gui.creator.tags")


local perk_form, module_mt, static = Module("state.gui.creator.perk_form")

local modifier_form, get_options

module_mt.__call = function(_, perk)
  local creator = State.gui.creator

  if perk.__type == class.choice then
    local choices = creator._choices
    choices[perk] = choices[perk] or 1
    local chosen_modifier = get_options(perk)[choices[perk]]

    local free_space = Fun.iter(perk.options)
      :map(function(o) return Entity.name(o):utf_len() end)
      :max() - Entity.name(chosen_modifier):utf_len()
    local rjust = math.floor(free_space / 2)
    local ljust = free_space - rjust

    table.insert(creator._movement_functions, function(dx)
      choices[perk] = (choices[perk] - 1 + dx) % #get_options(perk) + 1
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
  local name = perk.name

  if perk.get_description then
    get_tooltip = Fn.curry(perk.get_description, perk, State.player)
  else
    local new_action = -Query(perk):modify_actions(State.player, {})[1]
    if new_action then
      local header = "Способность: " .. Entity.name(new_action)
      name = name or header
      if new_action.get_description then
        get_tooltip = function()
          return Html.span {
            header and Html.h2 {header} or "",
            new_action:get_description(State.player),
          }
        end
      end
    end
  end

  return Html.span {
    get_tooltip = get_tooltip,
    name or Entity.name(perk),
  }
end

get_options = function(perk)
  return Fun.iter(perk.options)
    :filter(function(o)
      return Fun.iter(State.gui.creator._choices)
        :all(function(other_choice, i)
          return other_choice == perk
            or not class.is_equivalent(-Query(other_choice).options[i], o)
        end)
    end)
    :totable()
end

return perk_form
