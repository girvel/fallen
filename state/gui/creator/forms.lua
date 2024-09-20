local experience = require("mech.experience")


local forms, module_mt, static = Module("state.gui.creator.forms")

local perk_to_html = function(perk)
  local tooltip_sources = {}
  if perk.modify_actions then
    for _, action in ipairs(perk:modify_actions(State.player, {})) do
      table.insert(tooltip_sources, function()
        return Html.span {
          Html.p {"Новая способность: ", Entity.name(action)},
          action.get_description
            and Html.p {action:get_description(State.player)}
            or "",
        }
      end)
    end
  end

  return Html.p {
    "   ",
    Html.span {
      get_tooltip = function()
        return Html.span {
          Html.h1 {Entity.name(State.player)},
          unpack(Fun.iter(tooltip_sources)
            :map(Fun.op.call)
            :totable())
        }
      end,
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
