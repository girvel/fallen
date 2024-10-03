local sprite = require("tech.sprite")


local convert_line_breaks = function(token_list)
  local result = {{}}

  for _, token in ipairs(token_list) do
    local content = token.content
    while true do
      local i = content:find("\n")
      if not i then break end
      if i > 1 then
        table.insert(result[#result], Table.extend({}, token, {
          content = content:sub(1, i - 1),
        }))
      end
      table.insert(result, {})
      content = content:sub(i + 1)
    end
    if #content > 0 then
      table.insert(result[#result], Table.extend({}, token, {
        content = content,
      }))
    end
  end

  return result
end

-- TODO fast implementation
local _find_break = function(words, font, max_w)
  local last_line = ""
  local w = 0
  for i, word in ipairs(words) do
    local current_line = last_line .. (i == 1 and "" or " ") .. word
    w = font:getWidth(current_line)
    if w > max_w then
      return i - 1, w, last_line
    end
    last_line = current_line
  end
  return #words, w, last_line
end

local wrap_lines = function(token_lines, max_w)
  local result = {}
  local current_h = 0
  local max_line_h = 0
  for _, line in ipairs(token_lines) do
    table.insert(result, {})
    local current_w = 0
    if #line > 0 then
      max_line_h = 0
    end
    for _, token in ipairs(line) do
      max_line_h = math.max(max_line_h, sprite.get_font(token.font_size):getHeight())

      local current_content = token.content:split(" ")
      while #current_content > 0 do
        local break_i, w, inserted_line
          = _find_break(current_content, sprite.get_font(token.font_size), max_w - current_w)
        if break_i == 0 then
          table.insert(result, {})
          current_w = 0
          current_h = current_h + max_line_h
          max_line_h = sprite.get_font(token.font_size):getHeight()
        else
          table.insert(result[#result], Table.extend({}, token, {
            content = inserted_line,
            position = Vector({current_w, current_h}),
          }))
          current_content = Fun.iter(current_content)
            :drop_n(break_i)
            :totable()
          current_w = current_w + w
        end
      end
    end
    current_h = current_h + max_line_h
  end
  return result
end

-- TODO test how slow wrap & overall texting is
return Module("tech.texting._wrap", function(content, w)
  return wrap_lines(convert_line_breaks(content), w)
end)
