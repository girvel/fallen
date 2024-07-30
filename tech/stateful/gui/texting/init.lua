local special = require("tech.special")
local utf8 = require("utf8")
local html = require("tech.stateful.gui.texting.html")
local wrap = require("tech.stateful.gui.texting.wrap")


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
        content = link_text:gsub(" ", utf8.char(tonumber("00A0", 16))),
        link = link,
      })
      content = content:sub(j + 1)
    end
  end
  return result
end

local LINK_COLOR = Common.hex_color("3f5d92")

local generate_entities = function(token_lines, font, view)
  local result = {}
  for y, line in ipairs(token_lines) do
    for _, token in ipairs(line) do
      table.insert(result, Tablex.extend(
        special.text(
          token.link and {LINK_COLOR, token.content} or token.content,
          font,
          Vector({token.x, font:getHeight() * y})
        ),
        {
          view = view,
          on_click = token.link and function()
            State.gui.wiki:show(token.link)
          end or nil,
          size = Vector({font:getWidth(token.content), font:getHeight()}),
          link_flag = token.link or nil,
        }
      ))
    end
  end
  return result
end

return {
  generate_page = function(content, font, w, view)
    return generate_entities(
      wrap(parse_markdown(content), font, w),
      font, view
    )
  end,
  generate_html_page = function(content, font, w, view, args)
    return generate_entities(
      wrap(html.parse(content, args), font, w),
      font, view
    )
  end,
}
