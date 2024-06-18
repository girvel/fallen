local module_mt = {}
local module = setmetatable({}, module_mt)


-- TODO just assign them directly
local animation_methods = {
  animate = function(self, animation_name)
    self.animation.current = animation_name .. "_" .. (self.direction or "")
    if not self.animation.pack[self.animation.current] then
      self.animation.current = animation_name
    end
    self.animation.frame = 1
    self:animation_refresh()
  end,

  when_animation_ends = function(self, callback)
    self._on_animation_end = callback
  end,

  animation_refresh = function(self)
    if not self.animation.pack[self.animation.current] then return end
    self.sprite.image = self.animation.pack[self.animation.current][math.floor(self.animation.frame)]
  end
}

local animation_mt = {__index = animation_methods}

module_mt.__call = function(_, pack)
  local result = setmetatable({
    animation = {
      pack = pack,
      paused = false,
    },
    sprite = {},
    _on_animation_end = nil,
  }, animation_mt)

  result:animate("idle")
  return result
end

module.load_pack = function(folder_path)
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
    result[animation_name][frame_number] = love.graphics.newImage(folder_path .. "/" .. file_name)
  end
  return result
end

return module
