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

return {
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),

  show_page = function(self, path)
    local content = love.filesystem.read(path)
    Log.trace(parse_markdown(content))
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
