local transformers, module_mt, static = Module("tech.texting._transformers")

transformers.map = {}

transformers.map.head = function() return {} end

local h = function(level)
  return function(node, children, styles)
    return Table.concat(
      {
        Table.extend({content = "#" * level .. " "},
        styles["h%s" % level] or {},  -- TODO allow nil arguments in the middle?
        styles["h%s_prefix" % level])
      },
      Fun.iter(children)
        :map(function(child) return Table.extend(child, styles["h%s" % level]) end)
        :totable(),
      {{content = "\n\n"}}
    )
  end
end

transformers.map.h1 = h(1)
transformers.map.h2 = h(2)

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
    local link = node.attributes.href
    child.on_click = function()
      State.gui.wiki:show(link)
    end
    child.link_flag = true
    return Table.extend({}, styles.a or {}, child)
  end):totable()
end

transformers.map.hate = function(node, children, styles)
  return Table.concat(
    Fun.iter(children)
      :map(function(child)
        Table.extend(child, styles.hate)
        Table.extend(child, {
          on_update = function(self, dt)
            if self.delay > 0 then
              self.delay = self.delay - dt
              return
            end

            local color = self.sprite.text[1]
            if color[4] < 1 then
              self.sprite.text[1] = {color[1], color[2], color[3], color[4] + dt / self.appearance_time}
            end
          end,
          delay = child.delay + (node.attributes.offset or 0) * child.appearance_time,
        })
        child.color = {child.color[1], child.color[2], child.color[3], 0}
        return child
      end)
      :totable()
  )
end

transformers.map.stats = function(node, children, styles)
  return Fun.iter(children)
    :map(function(c) return Table.extend({color = Colors.from_hex("619cc3")}, c) end)
    :totable()
end

transformers.default = function(node, children, styles)
  return Fun.iter(children)
    :map(function(c) return Table.extend(c, styles[node.name]) end)
    :totable()
end

return transformers
