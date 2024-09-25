local class = require("mech.class")
local tags = require("state.gui.creator.tags")


local perk_form, module_mt, static = Module("state.gui.creator.perk_form")

local modifier_form, next_value

module_mt.__call = function(_, perk)
  local creator = State.gui.creator

  if perk.__type == class.choice then
    local choices = creator._choices
    choices[perk] = choices[perk] or next_value(perk.options, Table.last(perk.options), 1)
    -- TODO! can be null

    local free_space = Fun.iter(perk.options)
      :map(function(o) return Entity.name(o):utf_len() end)
      :max() - Entity.name(choices[perk]):utf_len()
    local rjust = math.floor(free_space / 2)
    local ljust = free_space - rjust

    table.insert(creator._movement_functions, function(dx)
      if dx == 0 then return end
      choices[perk] = next_value(perk.options, choices[perk], dx)
    end)
    local index = #creator._movement_functions

    return Html.p {
      tags.anchor(index),
      Entity.name(perk),
      ": ",
      tags.button(index, -1),
      " " * (1 + rjust),
      modifier_form(choices[perk]),
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

next_value = function(t, value, direction)
  local i = Table.index_of(t, value)

  local a, b, c
  if direction < 0 then
    a, b, c = 1, #t, 1
  else
    a, b, c = #t, 1, -1
  end

  for dx = a, b, c do
    local result = t[(i + dx - 1) % #t + 1]
    if Fun.pairs(State.gui.creator._choices)
      :all(function(_, p) return not class.is_equivalent(p, result) end)
    then return result end
  end
end

return perk_form
