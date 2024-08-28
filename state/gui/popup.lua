local texting = require("tech.texting")
local gui = require("tech.gui")
local sprite = require("tech.sprite")
local utf8 = require("utf8")


local W = 300
local MARGIN = 5

local popup, module_mt, static = Module("state.gui.popup")

State:add_multiple(texting.popup = function(position, relation, content, life_time)
  assert(relation == "above" or relation == "below")
  life_time = life_time or utf8.len(content) / 10 + 2

  -- TODO styles should probably be hierarchical, common in gui and specialized in wiki, creator, dialogue etc.
  local entities = State:add_multiple(texting.generate(
    "<span>%s</span>" % content, State.gui.wiki.styles, W, "scene_popup_content", {}
  ))

  -- TODO more elegant way to handle this, probably instead of texting.generate returning 
  --   multiple entities return {entities...}, w, h
  local last = entities[#entities]
  local size = Vector({
    Fun.iter(entities)
      :map(function(e) return e.position[1] + sprite.get_font(e.font_size):getWidth(e.sprite.text[2]) end)
      :max() - entities[1].position[1],
    last.position[2] - entities[1].position[2] + sprite.get_font(last.font_size):getHeight()
  })

  position = position * State.gui.views.scene:get_multiplier()  -- TODO rename scene_popup_* -> popup_*
  if relation == "above" then
    position = position + Vector.up * size[2]
  end
  position = position
    + Vector.left * math.floor(size[1] / 2)
    + Vector.right * math.floor(State.gui.views.scene:get_multiplier() * 1 / 2)

  for _, e in ipairs(entities) do
    e.position = e.position + position
  end

  table.insert(entities, State:add(gui.rect(
    position - Vector.one * MARGIN,
    "scene_popup_background",
    size + Vector.one * 2 * MARGIN,
    Colors.black
  )))

  for _, e in ipairs(entities) do
    e.life_time = life_time
  end

  return entities
end)

return popup
