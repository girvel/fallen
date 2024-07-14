local module = {}

module._periods = {}

module.period = function(identifier, period, dt)
  local result = false
  local value = module._periods[identifier] or 0
  value = value + dt
  if value > period then
    value = value - period
    result = true
  end
  module._periods[identifier] = value
  return result
end

module.hex_color = function(str)
  return Fun.range(3)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

module.get_color = function(image_data)
  for x = 0, image_data:getWidth() - 1 do
    for y = 0, image_data:getHeight() - 1 do
      local color = {image_data:getPixel(x, y)}
      if color[4] > 0 then return color end
    end
  end
end

module.volumed_sounds = function(path_beginning, volume)
  volume = volume or 1
  local _, _, directory = path_beginning:find("^(.*)/[^/]*$")
  return Fun.iter(love.filesystem.getDirectoryItems(directory))
    :map(function(filename) return directory .. "/" .. filename end)
    :filter(function(path) return path:startsWith(path_beginning) end)
    :map(function(path)
      local result = love.audio.newSource(path, "static")
      result:setVolume(volume)
      return result
    end)
    :totable()
end

module.set = function(list)
  return Fun.iter(list)
    :map(function(e) return e, true end)
    :tomap()
end

module.get_name = function(entity)
  return -Query(entity).name or -Query(entity).codename or "???"
end

return module
