local special = require("tech.special")
local utf8 = require("utf8")
local html = require("state.gui.texting.html")
local wrap = require("state.gui.texting.wrap")


local generate_entities = function(token_lines, view)
  local result = {}
  for y, line in ipairs(token_lines) do
    for _, token in ipairs(line) do
      local clean_copy = Tablex.extend({}, token)
      Fun.iter("x y link font content color" / " "):each(function(k)
        clean_copy[k] = nil
      end)

      table.insert(result, Tablex.extend(
        clean_copy,
        special.text(
          token.color and {token.color, token.content} or token.content,
          token.font,
          Vector({token.x, token.y})
        ),
        {
          view = view,
          on_click = token.on_click or token.link and function()
            State.gui.wiki:show(token.link)
          end,
          size = Vector({token.font:getWidth(token.content), token.font:getHeight()}),
          link_flag = token.link or nil,
        }
      ))
    end
  end
  return result
end

return {
  generate_html_page = function(content, styles, w, view, args)
    return generate_entities(
      wrap(html.parse(content, args, styles), w), view
    )
  end,
}
