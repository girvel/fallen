local special = require("tech.special")
local html = require("state.gui.texting.html")
local wrap = require("state.gui.texting.wrap")
local sprite = require("tech.sprite")


local texting, _, static = Module("state.gui.texting")

local generate_entities = function(token_lines, view)
  local result = {}
  for y, line in ipairs(token_lines) do
    for _, token in ipairs(line) do
      local clean_copy = Tablex.extend({}, token)
      Fun.iter("x y link font content color on_update" / " "):each(function(k)
        clean_copy[k] = nil
      end)

      local font = sprite.get_font(token.font_size)
      table.insert(result, Tablex.extend(
        clean_copy,
        special.text(
          token.color and {token.color, token.content} or token.content,
          token.font_size,
          Vector({token.x, token.y})
        ),
        {
          view = view,
          on_click = token.on_click or token.link and function()
            State.gui.wiki:show(token.link)
          end,
          size = Vector({font:getWidth(token.content), font:getHeight()}),
          link_flag = token.link or nil,
          ai = token.on_update and {observe = token.on_update},
        }
      ))
    end
  end
  return result
end

texting.generate_html_page = function(content, styles, w, view, args)
  return generate_entities(
    wrap(html.parse(content, args, styles), w), view
  )
end

return texting
