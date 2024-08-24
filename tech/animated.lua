local sprite = require("tech.sprite")


-- TODO REF review animation module & system
local module, module_mt, static = Module("tech.animated")

module._packs_cache = {}

local animation_methods = {
  animate = function(self, animation_name)
    if self._on_animation_end then
      self._on_animation_end:resolve(self)
      self._on_animation_end = nil
    end

    self:animation_set_paused(false)
    animation_name = animation_name or "idle"
    self.animation.current = animation_name .. "_" .. (self.direction or "")
    if not self.animation.pack[self.animation.current] then
      self.animation.current = animation_name  -- TODO! REF animation itself
    end
    if not self.animation.pack[self.animation.current] and animation_name ~= "idle" then
      return self:animate()
    end
    self.animation.frame = 1
    self:animation_refresh()

    if self.inventory then
      Fun.iter(self.inventory):each(function(slot, it)
        Query(it):animate(animation_name)
      end)
    end

    self._on_animation_end = Promise()
    return self._on_animation_end
  end,

  animation_refresh = function(self)
    if not self.animation.pack[self.animation.current] then return end
    self.sprite = self.animation.pack[self.animation.current][math.floor(self.animation.frame)]
  end,

  animation_set_paused = function(self, value)
    self.animation.paused = value
    for _, it in pairs(self.inventory or {}) do
      Query(it.animation).paused = value
    end
  end,
}

module_mt.__call = function(self, pack, pack_type)
  if type(pack) == "string" then
    if not self._packs_cache[pack] then
      self._packs_cache[pack] = pack_type == "atlas"
        and module.load_atlas_pack(pack)
        or module.load_pack(pack)
    end
    pack = self._packs_cache[pack]
  end

  local result = Table.extend({
    animation = {
      pack = pack,
      paused = false,
    },
    sprite = {},
    _on_animation_end = nil,
  }, animation_methods)

  result:animate("idle")
  return result
end

module.load_pack = function(folder_path, anchors)
  anchors = anchors or {}
  assert(love.filesystem.getInfo(folder_path), "No folder " .. folder_path)

  local result = {}
  for _, file_name in ipairs(love.filesystem.getDirectoryItems(folder_path)) do
    local i = file_name:find("%.png$")
    local frame_number = tonumber(file_name:sub(i - 2, i - 1))
    local animation_name
    if frame_number then
      animation_name = file_name:sub(0, i - 4)
    else
      frame_number = 1
      animation_name = file_name:sub(0, i - 1)
    end

    if not result[animation_name] then result[animation_name] = {} end

    local anchor = anchors[animation_name] and anchors[animation_name][frame_number]
    local image_data = love.image.newImageData(folder_path .. "/" .. file_name)
    result[animation_name][frame_number] = sprite.image(image_data, anchor)
  end
  return result
end

module.load_atlas_pack = function(folder_path, anchors)
  anchors = anchors or {}
  assert(love.filesystem.getInfo(folder_path), "No folder " .. folder_path)

  local result = {}
  for _, file_name in ipairs(love.filesystem.getDirectoryItems(folder_path)) do
    local break_i = file_name:find("%.png$")
    local frame_number = tonumber(file_name:sub(break_i - 2, break_i - 1))
    local animation_name
    if frame_number then
      animation_name = file_name:sub(0, break_i - 4)
    else
      frame_number = 1
      animation_name = file_name:sub(0, break_i - 1)
    end

    for i, direction_name in ipairs({"up", "left", "down", "right"}) do
      local full_name = animation_name .. "_" .. direction_name
      if not result[full_name] then result[full_name] = {} end
      result[full_name][frame_number] = sprite.from_atlas(
        folder_path .. "/" .. file_name, i, -Query(anchors)[full_name][frame_number]
      )
    end
  end
  return result
end

module.colored_pack = function(base_pack, color)
  return Fun.iter(base_pack)
    :map(function(animation_name, animation)
      return animation_name, Fun.iter(animation)
        :map(function(s)
          return sprite.image(s.data, s.anchor, color)
        end)
        :totable()
    end)
    :tomap()
end

module.get_render_position = function(entity)
  if not entity.movement_flag then
    return entity.position
  end
  return entity.position - Vector[entity.direction]
    * (1 - (entity.animation.frame - 1) / (#entity.animation.pack[entity.animation.current]))
end

return module
