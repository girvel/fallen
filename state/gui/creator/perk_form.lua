local class = require("mech.class")


local perk_form, module_mt, static = Module("state.gui.creator.perk_form")

local modifier_form = function(perk)
  local get_tooltip
  local prefix = ""

  local new_action = -Query(perk):modify_actions(State.player, {})[1]
  if new_action and new_action.get_description then
    get_tooltip = Fn(new_action:get_description(State.player))
    prefix = "Новая способность: "
  end

  return Html.span {
    get_tooltip = get_tooltip,
    prefix,
    Entity.name(perk),
  }
end

module_mt.__call = function(_, perk)
  if perk.__type == class.choice then
    local choices = State.gui.creator._choices
    choices[perk] = choices[perk] or 1
    local chosen_modifier = perk.options[choices[perk]]

    return Html.p {
      "   ",
      Entity.name(perk),
      ": < ",
      modifier_form(chosen_modifier),
      " >"
    }
  end

  return Html.p {
    "   ",
    modifier_form(perk),
  }
end

return perk_form
