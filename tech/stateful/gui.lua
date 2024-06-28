local special = require("tech.special")


local parse_markdown = function(content)
  local result = {}
  while #content > 0 do
    local i, j, link_text, link = Log.trace(content:find("%[([^%]]*)%]%(([^%)]*)%)"))
    if not i then
      table.insert(result, {
        content = content
      })
      content = ""
    else
      table.insert(result, {
        content = content:sub(1, i - 1),
      })
      table.insert(result, {
        content = link_text,
        link = link,
      })
      content = content:sub(j + 1)
    end
  end
  return result
end

local convert_line_breaks = function(token_list)
  local result = {{}}

  for _, token in ipairs(token_list) do
    local content = token.content
    while true do
      local i = content:find("\n")
      if not i then break end
      if i > 1 then
        table.insert(result[#result], {
          content = content:sub(1, i - 1),
          link = token.link,
        })
      end
      table.insert(result, {})
      content = content:sub(i + 1)
    end
    if #content > 0 then
      table.insert(result[#result], {
        content = content,
        link = token.link,
      })
    end
  end

  return result
end

return {
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),

  show_page = function(self, path)
    local content = love.filesystem.read(path)
    Log.trace(convert_line_breaks(parse_markdown(content)))
    -- self.text_entities = Fun.iter(parse_markdown(content))
    --   :map(function(e) return State:add(e) end)
    --   :totable()
  end,

  exit_wiki = function(self)
    if not self.text_entities then return end
    for _, e in ipairs(self.text_entities) do
      State:remove(e)
    end
    self.text_entities = nil
  end,
}
