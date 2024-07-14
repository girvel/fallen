local module_mt = {}
local module = setmetatable({}, module_mt)


-- TODO just assign them directly
local animation_methods = {
  animate = function(self, animation_name)
    self.animation.paused = false
    animation_name = animation_name or "idle"
    self.animation.current = animation_name .. "_" .. (self.direction or "")
    if not self.animation.pack[self.animation.current] then
      self.animation.current = animation_name
    end
    if not self.animation.pack[self.animation.current] and animation_name ~= "idle" then
      return self:animate()
    end
    self.animation.frame = 1
    self:animation_refresh()

    if self.inventory then
      Fun.iter(self.inventory):each(function(slot, it)
        it:animate(animation_name)
      end)
    end
  end,

  when_animation_ends = function(self, callback)
    self._on_animation_end = callback
  end,

  animation_refresh = function(self)
    if not self.animation.pack[self.animation.current] then return end
    self.sprite = self.animation.pack[self.animation.current][math.floor(self.animation.frame)]
  end
}

module_mt.__call = function(_, pack)
  local result = Tablex.extend({
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
    result[animation_name][frame_number] = Tablex.extend({  -- TODO unify w/ static_sprite
      image = love.graphics.newImage(image_data),
      image_data = image_data,
      color = Common.get_color(love.image.newImageData(folder_path .. "/" .. file_name))
    }, anchor and {anchor = anchor} or {})
  end
  return result
end

module.colored_pack = function(base_pack, color)
  return Fun.iter(base_pack)
    :map(function(animation_name, animation)
      return animation_name, Fun.iter(animation)
        :map(function(sprite)
          local image_data = sprite.image_data
          image_data:mapPixel(function(_, _, r, g, b, a)
            if a == 0 then return 0, 0, 0, 0 end
            if r == 0 and g == 0 and b == 0 then return 0, 0, 0, 1 end
            return unpack(color)
          end)
          return {
            image = love.graphics.newImage(image_data),
            image_data = image_data,
            color = color,
            anchor = sprite.anchor,
          }
        end)
        :totable()
    end)
    :tomap()
end

return module
