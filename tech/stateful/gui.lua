local special = require("tech.special")


-- each token is in format {content: string, link: string?}

local parse_markdown = function(content)
  local result = {}
  while #content > 0 do
    local i, j, link_text, link = content:find("%[([^%]]*)%]%(([^%)]*)%)")
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

-- local _find_break = function(line, font, w)
--   local break_i = #line
--   while true do
--     if font:getWidth(line:sub(1, break_i)) <= w then
--       if (break_i == #line or font:getWidth(line:sub(1, break_i + 1)) > w) then
--         return break_i
--       end
-- 
--       break_i = 
--     end
--     
--   end
-- end

-- TODO UTF-8
-- TODO fast implementation
-- TODO whitespace-based
local _find_break = function(line, font, max_w)
  local break_i = #line
  while true do
    local w = font:getWidth(line:sub(1, break_i))
    if w < max_w then return break_i, w end
    break_i = break_i - 1
  end
end

local wrap_lines = function(token_lines, font, max_w)
  local result = {}
  for _, line in ipairs(token_lines) do
    table.insert(result, {})
    local current_w = 0
    for _, token in ipairs(line) do
      local current_content = token.content
      while #current_content > 0 do
        local break_i, w = _find_break(current_content, font, max_w - current_w)
        if break_i == 0 then
          table.insert(result, {})
          current_w = 0
        else
          table.insert(result[#result], {
            content = current_content:sub(1, break_i),
            x = current_w,
            link = token.link,
          })
          current_content = current_content:sub(break_i + 1)
          current_w = current_w + w
        end
      end
    end
  end
  return result
end

local generate_entities = function(token_lines, font)
  local result = {}
  for y, line in ipairs(token_lines) do
    for _, token in ipairs(line) do
      table.insert(result, Tablex.extend(
        special.text(token.content, font, Vector({token.x, font:getHeight() * y})),
        {link = token.link}
      ))
    end
  end
  return result
end

return {
  LINK_COLOR = Common.hex_color("60b37e"),
  font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 12),

  show_page = function(self, path)
    local content = love.filesystem.read(path)
    self.text_entities = Fun.iter(
      generate_entities(
        wrap_lines(
          convert_line_breaks(
            parse_markdown(content)
          ),
          self.font,
          100
        ),
        self.font
      )
    )
      :map(function(e) return State:add(e) end)
      :totable()
  end,

  exit_wiki = function(self)
    if not self.text_entities then return end
    for _, e in ipairs(self.text_entities) do
      State:remove(e)
    end
    self.text_entities = nil
  end,
}
