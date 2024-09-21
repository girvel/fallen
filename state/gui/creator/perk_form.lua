local class = require("mech.class")


local perk_form, module_mt, static = Module("state.gui.creator.perk_form")

local modifier_form, anchor

module_mt.__call = function(_, perk)
  local creator = State.gui.creator

  if perk.__type == class.choice then
    local choices = creator._choices
    choices[perk] = choices[perk] or 1
    local chosen_modifier = perk.options[choices[perk]]

    table.insert(creator._movement_functions, function(dx)
      choices[perk] = (choices[perk] - 1 + dx) % #perk.options + 1
    end)

    return Html.p {
      anchor(#creator._movement_functions),
      Entity.name(perk),
      ": < ",
      modifier_form(chosen_modifier),
      " >",
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

anchor = function(index)
  return Html.span {
    " ",
    Html.span {
      on_update = function(self)
        self.sprite.text = State.gui.creator._current_selection_index == index
          and ">"
          or " "
      end,
      " ",
    },
    " ",
  }
end

return perk_form
