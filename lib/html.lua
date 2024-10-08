local htmlparser = require("lib.vendor.htmlparser")


local html_api = {}
local html = setmetatable({}, {
  __call = Fn(html_api),
  __index = function(_, item)
    return function(t)
      assert(t.__type ~= html_api.tag)

      local attributes = {}
      for k, v in pairs(t) do
        if type(k) == "string" then
          attributes[k] = v
        end
      end

      local content = {}
      for _, v in ipairs(t) do
        if type(v) == "table" and v.__type == html_api.tag then
          table.insert(content, v)
        else
          table.insert(content, tostring(v))
        end
      end

      return html_api.tag {
        name = item,
        attributes = attributes,
        content = content,
      }
    end
  end,
})

local tag_methods = {}
local tag_mt = {__index = tag_methods}

html_api.tag = Type .. function(_, t)
  assert(t.name and t.attributes and t.content)
  return setmetatable(t, tag_mt)
end

tag_methods.find_by_name = function(self, name)
  return Fun.iter(self.content)
    :filter(function(e) return -Query(e).name == name end)
    :nth(1)
end

tag_methods.get_title = function(self)
  local tag = -Query(self):find_by_name("head"):find_by_name("title")
  if not tag then return nil end
  return table.concat(tag.content, "")
end

tag_mt.__tostring = function(self)
  return "<%s%s>\n%s\n</%s>" % {
    self.name,
    Fun.pairs(self.attributes)
      :map(function(k, v) return " %s=%s" % {k, Inspect(v)} end)
      :reduce(Fun.op.concat, ""),
    Fun.iter(self.content)
      :map(tostring)
      :reduce(Fun.op.concat, "")
      :indent(),
    self.name,
  }
end

local visit_node

html_api.parse = function(html_string, attribute_factories)
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

  return html_api.tag {
    name = node.name,
    attributes = attributes,
    content = content,
  }
end

local build_cell

html_api.build_table = function(matrix)
  return html.table(Fun.iter(matrix)
    :map(function(row)
      return html.tr(Fun.iter(row):map(build_cell):totable())
    end)
    :totable()
  )
end

build_cell = function(content)
  if -Query(content).__type == html_api.tag and content.name == "tline" then
    return content
  end
  return html.td {content}
end

return html
