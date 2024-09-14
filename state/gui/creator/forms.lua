local translation = require("tech.translation")
local experience = require("mech.experience")


local forms, module_mt, static = Module("state.gui.creator.forms")

forms.class = static .. function(mixin)
  return Html(function()
    return span {
      h2 {"%s%s" % {translation.class[mixin.class.codename], mixin.level}},
      unpack(Fun.iter(experience.get_progression(mixin.class, mixin.level))
        :map(function(perk) return p {Entity.name(perk)} end)
        :totable()
      ),
    }
  end)
end

return forms
