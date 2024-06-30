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

-- TODO UTF-8
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

local wrap_lines = function(token_lines, font, max_w)
  local result = {}
  for _, line in ipairs(token_lines) do
    table.insert(result, {})
    local current_w = 0
    for _, token in ipairs(line) do
      local current_content = token.content:split(" ")
      while #current_content > 0 do
        local break_i, w, inserted_line = _find_break(current_content, font, max_w - current_w)
        if break_i == 0 then
          table.insert(result, {})
          current_w = 0
        else
          table.insert(result[#result], {
            content = inserted_line,
            x = current_w,
            link = token.link,
          })
          current_content = Fun.iter(current_content)
            :drop_n(break_i)
            :totable()
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
        {
          link = token.link,
          size = Vector({font:getWidth(token.content), font:getHeight()})
        }
      ))
    end
  end
  return result
end

return {
  generate_wiki_page = function(content, font, w)
    return generate_entities(
      wrap_lines(
        convert_line_breaks(
          parse_markdown(content)
        ),
        font, w
      ),
      font
    )
  end
}
