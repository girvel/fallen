local htmlparser = require("lib.htmlparser")


local html = {}

local transformers = {
  head = function() return {} end,
  h1 = function(node, children, styles)
    children = Tablex.concat(unpack(children))

    return Tablex.concat(
      {Tablex.extend({content = "# "}, styles.h1_prefix)},
      Fun.iter(children)
        :map(function(child) return Tablex.extend(styles.h1, child) end)
        :totable(),
      {{content = "\n\n"}}
    )
  end,
  p = function(node, children, styles)
    children = Tablex.concat(unpack(children))
    return Tablex.concat(children, {{content = "\n\n"}})
  end,
  li = function(node, children, styles)
    children = Tablex.concat(unpack(children))
    return Tablex.concat({{content = "- "}}, children, {{content = "\n"}})
  end,
  a = function(node, children, styles)
    children = Tablex.concat(unpack(children))
    Fun.iter(children):each(function(child)
      child.link = node.attributes.href
    end)
    return children
  end,
}

transformers.ul = transformers.p

local transform_default_node = function(node, children, styles)
  if #children == 0 then
    return {{content = node:getcontent()}}
  end
  return Tablex.concat(unpack(children))
end

local get_availability = function(root, args)
  local condition = root.attributes["if"]
  if not condition then return true end

  local predicate = assert(loadstring(
    [[
      return function(args)
        %s
        return %s
      end
    ]] % {
      Fun.iter(args)
        :map(function(name) return "local %s = args.%s\n" % {name, name} end)
        :reduce(Fun.op.concat, ""),
      condition,
    }
  ))()
  return predicate(args)
end

local postprocess = function(root, content, styles)
  if root.attributes.color then
    Fun.iter(content):each(function(token)
      token.color = Common.hex_color(root.attributes.color)
    end)
  end
  return Fun.iter(content):map(function(token)
    return Tablex.extend({}, styles.default, token)
  end):totable()
end

local visit_html
visit_html = function(root, args, styles)
  if not get_availability(root, args) then return {} end
  local nodes = Fun.iter(root.nodes)
    :map(function(node) return visit_html(node, args, styles) end)
    :totable()
  if #nodes == 0 then
    nodes = {{{content = root:getcontent()}}}
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

return html
