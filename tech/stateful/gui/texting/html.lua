local htmlparser = require("lib.htmlparser")


local html = {}

local transformers = {
  head = function() return {} end,
  h1 = function(node, children)
    children = Tablex.concat(unpack(children))
    return Tablex.concat({{content = "# "}}, children, {{content = "\n\n"}})
  end,
  p = function(node, children)
    children = Tablex.concat(unpack(children))
    return Tablex.concat(children, {{content = "\n\n"}})
  end,
  li = function(node, children)
    children = Tablex.concat(unpack(children))
    return Tablex.concat({{content = "- "}}, children, {{content = "\n"}})
  end,
}

transformers.ul = transformers.p

local transform_default_node = function(node, children)
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

local visit_html
visit_html = function(root, args)
  if not get_availability(root, args) then return {} end
  local nodes = Fun.iter(root.nodes)
    :map(function(node) return visit_html(node, args) end)
    :totable()
  if #nodes == 0 then
    nodes = {{{content = root:getcontent()}}}
  end
  return (transformers[root.name] or transform_default_node)(root, nodes)
end

html.parse = function(content, args)
  return visit_html(htmlparser.parse(content), args)
end

html.is_available = function(content, args)
  return get_availability(htmlparser.parse(content)("html")[1], args)
end

html.get_title = function(content)
  return htmlparser.parse(content)("head")[1]("title")[1]:getcontent()
end

return html
