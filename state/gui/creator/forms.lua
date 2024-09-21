local experience = require("mech.experience")


local forms, module_mt, static = Module("state.gui.creator.forms")

local perk_to_html = function(perk)
  local get_tooltip
  local prefix = ""

  local new_action = -Query(perk):modify_actions(State.player, {})[1]
  if new_action and new_action.get_description then
    get_tooltip = Fn(new_action:get_description(State.player))
    prefix = "Новая способность: "
  end

  return Html.p {
    "   ",
    Html.span {
      get_tooltip = get_tooltip,
      prefix,
      Entity.name(perk),
    },
  }
end

forms.class = static .. function(mixin)
  return Html.span {
    "   ",
    Html.h2 {"Класс: %s, уровень %s" % {mixin.class.name, mixin.level}},
    unpack(Fun.iter(experience.get_progression(mixin.class, mixin.level))
      :filter(function(p) return not p.hidden end)
      :map(perk_to_html)
      :totable()
    ),
  }
end

return forms
