local htmlparser = require("lib.vendor.htmlparser")


local html_functions = {}
local html = setmetatable({}, {
  __call = Fn(html_functions),
  __index = function(_, item)
    return function(t)
      local attributes = {}
      for k, v in pairs(t) do
        if type(k) == "string" then
          attributes[k] = v
        end
      end

      local content = {}
      for _, v in ipairs(t) do
        if type(v) == "table" and v.__type == html_functions.tag then
          table.insert(content, v)
        else
          table.insert(content, tostring(v))
        end
      end

      return html_functions.tag {
        name = item,
        attributes = attributes,
        content = content,
      }
    end
  end,
})

html_functions.tag = Type .. function(_, t)
  assert(t.name and t.attributes and t.content)
  return t
end

local visit_node

html_functions.parse = function(html_string, attribute_factories)
  local root = htmlparser.parse(html_string)
  return visit_node(root, attribute_factories or {})
end

visit_node = function(node, attribute_factories, preserve_whitespace)
  if node.name == "root" then
    return visit_node(node.nodes[1], attribute_factories, preserve_whitespace)
  end

  preserve_whitespace = preserve_whitespace or node.name == "pre"

  local prepare_text = function(text)
    text = text:gsub("&gt;", ">"):gsub("&lt;", "<")
    if not preserve_whitespace then
      text = text:gsub("\n", ""):gsub("%s+", " ")
    end
    return text
  end

  local content = {}
  local raw_content = node:getcontent()
  local i, j

  for _, element in ipairs(node.nodes) do
    i, j = raw_content:find(element:gettext(), 1, true)
    if i > 1 then
      table.insert(content, prepare_text(raw_content:sub(1, i - 1)))
    end
    table.insert(content, visit_node(element, attribute_factories, preserve_whitespace))
    raw_content = raw_content:sub(j + 1)
  end

  if #raw_content > 0 then
    table.insert(content, prepare_text(raw_content))
  end

  local attributes = {}
  for k, v in pairs(node.attributes) do
    local factory = attribute_factories[k]
    if factory then
      v = factory(v)
    end
    attributes[k] = v
  end

  return html_functions.tag {
    name = node.name,
    attributes = attributes,
    content = content,
  }
end

return html
