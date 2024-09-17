local html_functions = {}
local html = setmetatable({}, {
  -- TODO! restructure libs: instead of extensions/ use essential/
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
        table.insert(content, v)
      end

      print(require("lib.vendor.inspect")(html_functions.tag {}))

      return html_functions.tag {
        tag = item,
        attributes = attributes,
        content = content,
      }
    end
  end,
})

html_functions.tag = Type .. function(t) return t end

return html
