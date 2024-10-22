local sprite = require("tech.sprite")


-- TODO REF review animation module & system
local module, module_mt, static = Module("tech.animated")

module._packs_cache = {}

local animation_methods = {
  animate = function(self, animation_name)
    animation_name = animation_name or "idle"

    if self.animation._on_end then
      self.animation._on_end:resolve(self)
      self.animation._on_end = nil
    end
    self:animation_set_paused(false)

    for _, candidate in ipairs({
      "%s_%s" % {animation_name, self.direction or "right"},
      animation_name,
    }) do
      self.animation.current = self.animation.pack[candidate]
      if self.animation.current then break end
    end

    self.animation.frame = 1
    self:animation_refresh()

    for _, it in pairs(self.inventory or {}) do
      if not it.animated_independently_flag then
        Query(it):animate(animation_name)
      end
    end

    self.animation._on_end = Promise()
    return self.animation._on_end
  end,

  animation_refresh = function(self)
    if not self.animation.current then return end
    self.sprite = self.animation.current[math.floor(self.animation.frame)]
  end,

  animation_set_paused = function(self, value)
    self.animation.paused = value
    for _, it in pairs(self.inventory or {}) do
      if not it.animated_independently_flag then
        Query(it.animation).paused = value
      end
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
      _on_end = nil,
    },
    sprite = {},
  }, animation_methods)

  result:animate()
  return result
end

module.load_pack = function(folder_path)
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

    if not result[animation_name] then
      result[animation_name] = {codename = animation_name}
    end

    local image_data = love.image.newImageData(folder_path .. "/" .. file_name)
    result[animation_name][frame_number] = sprite.image(image_data)
  end
  return result
end

module.load_atlas_pack = function(folder_path)
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
      if not result[full_name] then result[full_name] = {codename = full_name} end
      result[full_name][frame_number] = sprite.from_atlas(
        folder_path .. "/" .. file_name, i
      )
    end
  end
  return result
end

module.colored_pack = function(base_pack, color)
  return Fun.iter(base_pack)
    :map(function(animation_name, animation)
      return animation_name, Table.extend(Fun.iter(animation)
        :map(function(s)
          return sprite.image(s.data, color, s.anchors)
        end)
        :totable(), {codename = animation_name})
    end)
    :tomap()
end

module.get_render_position = function(entity)
  return entity.position
  -- if not entity.movement_flag then
  --   return entity.position
  -- end
  -- return entity.position - Vector[entity.direction]
  --   * (1 - (entity.animation.frame - 1) / (#entity.animation.current))
end

return module
