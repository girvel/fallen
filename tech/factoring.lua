local sprite = require("tech.sprite")


local factoring, module_mt, static = Module("tech.factoring")

factoring.from_atlas = function(t, atlas, mixin, names)
  assert(not t._factoring_codenames, "can do factoring.from_atlas only once")

  for i, name in ipairs(names) do
    if name then
      local current_mixin
      if type(mixin) == "function" then
        current_mixin = mixin(name, sprite.get_atlas_position(atlas, i))
      else
        current_mixin = mixin
      end
      t[i] = function()
        return Table.extend({
          sprite = sprite.from_atlas(atlas, i),
          codename = name,
        }, current_mixin)
      end
      t[name] = t[i]
    end
  end

  t._factoring_codenames = Fun.iter(names)
    :enumerate()
    :map(function(k, v) return v, k end)
    :tomap()
end

factoring.extend = function(t, codename, ...)
  assert(t._factoring_codenames, "can extend atlas only after factoring.from_atlas")

  local k = t._factoring_codenames[codename]
  local wrapped = t[k]
  local mixins = {...}
  t[k] = function(...)
    return Table.extend(wrapped(...), unpack(mixins))
  end
  t[codename] = t[k]
end

return factoring
