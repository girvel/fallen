local sprite = require("tech.sprite")


local factoring, module_mt, static = Module("tech.factoring")

factoring.from_atlas = function(t, atlas, mixin, names)
  for i, name in ipairs(names) do
    if name then
      local current_mixin
      if type(mixin) == "function" then
        current_mixin = mixin(name)
      else
        current_mixin = mixin
      end
      t[name] = function()
        return Tablex.extend({
          sprite = sprite.from_atlas(atlas, i),
          codename = name,
        }, current_mixin)
      end
    end
  end
end

factoring.extend = function(t, k, ...)
  local wrapped = t[k]
  local mixins = {...}
  t[k] = function(...)
    return Tablex.extend(wrapped(...), unpack(mixins))
  end
end

return factoring
