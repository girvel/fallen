local transformers, module_mt, static = Module("tech.texting._transformers")

transformers.map = {}

transformers.map.head = function() return {} end

transformers.map.h1 = function(node, children, styles)
  return Table.concat(
    {Table.extend({content = "# "}, styles.h1, styles.h1_prefix)},
    Fun.iter(children)
      :map(function(child) return Table.extend(child, styles.h1) end)
      :totable(),
    {{content = "\n\n"}}
  )
end

transformers.map.h2 = function(node, children, styles)
  return Table.concat(
    {Table.extend({content = "# "}, styles.h2, styles.h2_prefix)},
    Fun.iter(children)
      :map(function(child) return Table.extend(child, styles.h2) end)
      :totable(),
    {{content = "\n\n"}}
  )
end

transformers.map.p = function(node, children, styles)
  return Table.concat(children, {{content = "\n\n"}})
end

transformers.map.br = function()
  return {{content = "\n"}}
end

transformers.map.ul = transformers.map.p

transformers.map.li = function(node, children, styles)
  return Table.concat({{content = "- "}}, children, {{content = "\n"}})
end

transformers.map.a = function(node, children, styles)
  return Fun.iter(children):map(function(child)
    -- TODO! directly generate a function
    child.link = node.attributes.href
    return Table.extend({}, styles.a or {}, child)
  end):totable()
end

transformers.map.hate = function(node, children, styles)
  return Table.concat(
    Fun.iter(children)
      :map(function(child)
        local result = Table.extend(child, styles.hate, {
          on_update = function(self, dt)
            if self.delay > 0 then
              self.delay = self.delay - dt
              return
            end

            local color = self.sprite.text[1]
            if color[4] < 1 then
              color[4] = color[4] + dt / self.appearance_time
            end
          end,
        })
        result.color[4] = 0
        return result
      end)
      :totable()
  )
end

transformers.map.script = function()
  return {}
end

transformers.map.stats = function(node, children, styles)
  return Fun.iter(children)
    :map(function(c) return Table.extend({color = Colors.from_hex("619cc3")}, c) end)
    :totable()
end

transformers.default = function(node, children, styles)
  return Fun.iter(children)
    :map(function(c) return Table.extend({}, styles[node.name] or {}, c) end)
    :totable()
end

return transformers
