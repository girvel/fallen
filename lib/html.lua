local html_functions = {}
local html = setmetatable({}, {
  -- TODO! use .tests for tests?
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
        tag = item,
        attributes = attributes,
        content = content,
      }
    end
  end,
})

html_functions.tag = Type .. function(_, t) return t end

return html
