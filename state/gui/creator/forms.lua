local experience = require("mech.experience")
local perk_form = require("state.gui.creator.perk_form")


local forms, module_mt, static = Module("state.gui.creator.forms")

forms.class = static .. function(mixin)
  return Html.span {
    "   ",
    Html.h2 {"Класс: %s, уровень %s" % {mixin.class.name, mixin.level}},
    unpack(Fun.iter(mixin.class.progression_table)
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
    ),
  }
end

return forms
