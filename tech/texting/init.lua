local gui = require("tech.gui")
local wrap = require("tech.texting.wrap")
local sprite = require("tech.sprite")


local texting, _, static = Module("tech.texting")

texting.parse = require("tech.texting._parse")

local generate_entities = function(token_lines, view)
  local result = {}
  for y, line in ipairs(token_lines) do
    for _, token in ipairs(line) do
      local clean_copy = Table.extend({}, token)
      Fun.iter("x y link font content color on_update" / " "):each(function(k)
        clean_copy[k] = nil
      end)

      local font = sprite.get_font(token.font_size)
      table.insert(result, Table.extend(
        clean_copy,
        gui.text(
          token.color and {Table.extend({}, token.color), token.content} or token.content,
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

texting.generate = function(content, styles, w, view, args)
  return generate_entities(
    wrap(html.tokenize(content, args, styles), w), view
  )
end

local MARGIN = 5

texting.popup = function(position, relation, view, content, styles, width)
  assert(relation == "above" or relation == "below")

  local entities = texting.generate(
    "<span>%s</span>" % content, styles, width, view, {}
  )

  -- TODO more elegant way to handle this, probably instead of texting.generate returning 
  --   multiple entities return {entities...}, w, h
  local last = entities[#entities]
  local size = Vector({
    Fun.iter(entities)
      :map(function(e) return e.position[1] + sprite.get_font(e.font_size):getWidth(e.sprite.text[2]) end)
      :max() - entities[1].position[1],
    last.position[2] - entities[1].position[2] + sprite.get_font(last.font_size):getHeight()
  })

  if relation == "above" then
    position = position
      + Vector.up * size[2]
      + Vector.left * math.floor(size[1] / 2)
  else
    position = position
      + Vector.one * MARGIN * 2
  end

  for _, e in ipairs(entities) do
    e.position = e.position + position
  end

  table.insert(entities, 1, gui.rect(
    position - Vector.one * MARGIN,
    view .. "_background",
    size + Vector.one * 2 * MARGIN,
    Colors.black()
  ))

  return entities
end

return texting
