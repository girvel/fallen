local experience = require("mech.experience")
local perk_form = require("state.gui.creator.perk_form")


local forms, module_mt, static = Module("state.gui.creator.forms")

forms.class = static .. function(mixin)
  return Html.span {
    "   ",
    Html.h2 {"Класс: %s, уровень %s" % {mixin.class.name, mixin.level}},
    unpack(Fun.iter(experience.get_progression(mixin.class, mixin.level))
      :filter(function(p) return not p.hidden end)
      :map(perk_form)
      :totable()
    ),
  }
end

return forms
