local transformers = require("tech.texting.html.transformers")
local htmlparser = require("lib.vendor.htmlparser")


local html, _, static = Module("tech.texting.html")

local run_script = function(script, args, script_name)
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
    local f, err = loadstring(
      "return function(self)\n"
      .. root.attributes[event]:gsub("&gt;", ">"):gsub("&lt;", "<")
      .. "\nend"
    )()
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
      token.color = Colors.from_hex(root.attributes.color)
    end)
  end
  if root.attributes.tooltip then
    local tooltip_content = love.filesystem.read("/assets/html/tooltips/%s.html" % root.attributes.tooltip)
    local f = function() return tooltip_content end
    for _, token in ipairs(content) do
      token.get_tooltip = f
    end
  end
  assign_event("on_click", root, content)
  assign_event("on_hover", root, content)
  assign_event("on_update", root, content)
  return Fun.iter(content):map(function(token)
    return Table.extend({}, styles.default, token)
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
    Table.concat(
      nodes,
      {{content = prepare(content:sub(1, i - 1))}},
      visit_html(node, args, styles, preserve_whitespace)
    )
    content = content:sub(j + 1)
  end
  if #content > 0 then
    Table.concat(nodes, {{content = prepare(content)}})
  end

  local result = (transformers.map[root.name] or transformers.default)(root, nodes, styles)
  return postprocess(root, result, styles)
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
