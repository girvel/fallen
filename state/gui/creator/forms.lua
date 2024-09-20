local translation = require("tech.translation")
local experience = require("mech.experience")


local forms, module_mt, static = Module("state.gui.creator.forms")

local perk_to_html = function(perk)
  return Html.p {
    "   ",
    Html.span {tooltip = perk.codename, Entity.name(perk)},
  }
end

forms.class = static .. function(mixin)
  return Html.span {
    "   ",
    Html.h2 {"Класс: %s, уровень %s" % {
      translation.class[mixin.class.codename], mixin.level
    }},
    unpack(Fun.iter(experience.get_progression(mixin.class, mixin.level))
      :map(perk_to_html)
      :totable()
    ),
  }
end

return forms
