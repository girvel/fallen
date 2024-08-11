local sprite = require("tech.sprite")


local factoring, module_mt, static = Module("tech.factoring")

factoring.from_atlas = function(atlas, mixin, names)
  local result = {}
  for i, name in ipairs(names) do
    if name then
      result[name] = function()
        return Tablex.extend({
          sprite = sprite.from_atlas(atlas, i),
          codename = name,
        }, mixin)
      end
    end
  end
  return result
end

factoring.extend = function(t, k, mixin)
  local wrapped = t[k]
  t[k] = function(...)
    return Tablex.extend(wrapped(...), mixin)
  end
end

return factoring
