local htmlparser = require("lib.htmlparser")


local html, _, static = Module("state.gui.texting.html")

local transformers = {
  head = function() return {} end,
  h1 = function(node, children, styles)
    return Tablex.concat(
      {Tablex.extend({content = "# "}, styles.h1_prefix)},
      Fun.iter(children)
        :map(function(child) return Tablex.extend(child, styles.h1) end)
        :totable(),
      {{content = "\n\n"}}
    )
  end,
  h2 = function(node, children, styles)
    return Tablex.concat(
      {Tablex.extend({content = "# "}, styles.h2_prefix)},
      Fun.iter(children)
        :map(function(child) return Tablex.extend(child, styles.h2) end)
        :totable(),
      {{content = "\n\n"}}
    )
  end,
  p = function(node, children, styles)
    return Tablex.concat(children, {{content = "\n\n"}})
  end,
  li = function(node, children, styles)
    return Tablex.concat({{content = "- "}}, children, {{content = "\n"}})
  end,
  a = function(node, children, styles)
    return Fun.iter(children):map(function(child)
      child.link = node.attributes.href
      return Tablex.extend({}, styles.a or {}, child)
    end):totable()
  end,
  hate = function(node, children, styles)
    return Tablex.concat(
      Fun.iter(children)
        :map(function(child)
          local result = Tablex.extend(child, styles.hate, {
            on_update = function(self, event)
              local dt = unpack(event)
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
  end,
  script = function()
    return {}
  end,
}

transformers.ul = transformers.p

local transform_default_node = function(node, children, styles)
  return children
end

local run_script = function(script, args)
  return assert(loadstring(
    [[
      return function(args)
        %s
        %s
      end
    ]] % {
      Fun.iter(args)
        :map(function(name) return "local %s = args.%s\n" % {name, name} end)
        :reduce(Fun.op.concat, ""),
      script,
    }
  ))()(args)
end

local get_availability = function(root, args)
  local condition = root.attributes["if"]
  if not condition then return true end
  return run_script("return " .. condition, args)
end

local assign_event = function(event, root, content)
  if root.attributes[event] then
    local f, err = loadstring(root.attributes[event])
    if f then
      Fun.iter(content):each(function(token) token[event] = f end)
    else
      Log.error("Error loading %s attribute\n%s\n%s" % {
        event, root:gettext(), err
      })
    end
  end
end

local postprocess = function(root, content, styles)
  if root.attributes.color then
    Fun.iter(content):each(function(token)
      token.color = Common.hex_color(root.attributes.color)
    end)
  end
  assign_event("on_click", root, content)
  assign_event("on_hover", root, content)
  return Fun.iter(content):map(function(token)
    return Tablex.extend({}, styles.default, token)
  end):totable()
end

local visit_html
visit_html = function(root, args, styles, preserve_whitespace)
  preserve_whitespace = preserve_whitespace or root.name == "pre"
  if not get_availability(root, args) then return {} end
  if root.root == root then
    return visit_html(root.nodes[1], args, styles, preserve_whitespace)
  end

  local prepare = function(content)
    content = content:gsub("&gt;", ">"):gsub("&lt;", "<")
    if not preserve_whitespace then
      content = content:gsub("\n", ""):gsub("%s+", " ")
    end
    return content
  end

  local nodes = {}
  local content = root:getcontent()
  local i, j
  for _, node in ipairs(root.nodes) do
    i, j = content:find(node:gettext(), 1, true)
    Tablex.concat(
      nodes,
      {{content = prepare(content:sub(1, i - 1))}},
      visit_html(node, args, styles, preserve_whitespace)
    )
    content = content:sub(j + 1)
  end
  if #content > 0 then
    Tablex.concat(nodes, {{content = prepare(content)}})
  end

  local result = (transformers[root.name] or transform_default_node)(root, nodes, styles)
  return postprocess(root, result, styles)
end

html.parse = function(content, args, styles)
  assert(styles and styles.default)
  return visit_html(htmlparser.parse(content), args, styles)
end

html.is_available = function(content, args)
  return get_availability(htmlparser.parse(content)("html")[1], args)
end

html.get_title = function(content)
  return htmlparser.parse(content)("head")[1]("title")[1]:getcontent()
end

html.run_scripts = function(content, args)
  for _, script in pairs(htmlparser.parse(content)("script")) do
    run_script(script:getcontent(), args)
  end
end

return html
