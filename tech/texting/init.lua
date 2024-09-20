local wrap = require("tech.texting._wrap")
local generate = require("tech.texting._generate")
local streamer = require("tech.texting._streamer")
local gui = require("tech.gui")
local sprite = require("tech.sprite")


local texting, _, static = Module("tech.texting")

texting.parse = require("tech.texting._parse")

texting.generate = function(root, styles, w, view, args)
  return Log.trace(generate(
    wrap(
      streamer.visit(root, args, styles), w
    ), view
  ))
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
