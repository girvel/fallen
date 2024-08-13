local common = {}

common.get_by_path = function(t, identifier, i)
  i = i or 1
  if t == nil then return end
  if i > #identifier then return t end
  return common.get_by_path(t[identifier[i]], identifier, i + 1)
end

common.set_by_path = function(t, identifier, value, i)
  i = i or 1
  if i == #identifier then
    t[identifier[i]] = value
    return
  end
  if not t[identifier[i]] then
    t[identifier[i]] = {}
  end
  return common.set_by_path(t[identifier[i]], identifier, value, i + 1)
end

common._periods = {}

common.relative_period = function(period, dt, ...)
  local identifier = {...}

  local result = false
  local value = common.get_by_path(common._periods, identifier) or 0
  value = value + dt
  if value > period then
    value = value - period
    result = true
  end
  common.set_by_path(common._periods, identifier, value)
  return result
end

common.period = function(period, ...)
  local identifier = {...}
  local start_time = common.get_by_path(common._periods, identifier) or love.timer.getTime()
  if love.timer.getTime() - start_time > period then
    common.set_by_path(common._periods, identifier, start_time + period)
    return true
  end
  return false
end

common.reset_period = function(...)
  common.set_by_path(common._periods, {...}, nil)
end

common.hex_color = function(str)
  return Fun.range(#str / 2)
    :map(function(i) return tonumber(str:sub(i * 2 - 1, i * 2), 16) / 255 end)
    :totable()
end

common.color_to_hex = function(color)
  return Fun.iter(color)
    :map(function(v) return "%x" % (v * 255) end)
    :reduce(Fun.op.concat, "")
end

common.get_color = function(image_data)
  for x = 0, image_data:getWidth() - 1 do
    for y = 0, image_data:getHeight() - 1 do
      local color = {image_data:getPixel(x, y)}
      if (color[1] > 0 or color[2] > 0 or color[3] > 0) and color[4] > 0 then
        return color
      end
    end
  end
end

common.set = function(list)
  return Fun.iter(list)
    :map(function(e) return e, true end)
    :tomap()
end

common.get_name = function(entity)
  return -Query(entity).name or -Query(entity).codename or "???"
end

common.resume_logged = function(coroutine_, ...)
  local success, message = coroutine.resume(coroutine_, ...)
  if not success then
    Log.error("Coroutine error: %s\n%s" % {message, debug.traceback(coroutine_)})
  end
end

common.number_type = function(number)
  if type(number) ~= "number" then return end
  if math.floor(number) == number then return "integer" end
  return "float"
end

common.loop = function(v, loop)
  return (v - 1) % loop + 1
end

common.last = function(t)
  return t[#t]
end

return common
