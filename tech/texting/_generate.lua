local gui = require("tech.gui")
local sprite = require("tech.sprite")


return function(lines, view)
  local result = {}
  for _, line in ipairs(lines) do
    for _, token in ipairs(line) do
      local clean_copy = Table.extend({}, token)
      Fun.iter("content color on_update" / " "):each(function(k)
        clean_copy[k] = nil
      end)

      local font = sprite.get_font(token.font_size)
      table.insert(result, Table.extend(
        clean_copy,
        gui.text(
          token.color and {Table.extend({}, token.color), token.content} or token.content,
          token.font_size
        ),
        {
          view = view,
          size = Vector({font:getWidth(token.content), font:getHeight()}),
          ai = token.on_update and {observe = function(_, ...) return token.on_update(...) end},
        }
      ))
    end
  end
  return result
end
