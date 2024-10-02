local ffi = require("ffi")


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
  local start_time = common.get_by_path(common._periods, identifier)
  if not start_time then
    start_time = love.timer.getTime()
    common.set_by_path(common._periods, identifier, start_time)
  end
  if love.timer.getTime() - start_time > period then
    common.set_by_path(common._periods, identifier, start_time + period)
    return true
  end
  return false
end

common.reset_period = function(...)
  common.set_by_path(common._periods, {...}, nil)
end

common.set = function(list)
  return Fun.iter(list)
    :map(function(e) return e, true end)
    :tomap()
end

common.resume_logged = function(coroutine_, ...)
  local t = love.timer.getTime()
  local success, message = coroutine.resume(coroutine_, ...)
  t = love.timer.getTime() - t
  if t > 0.25 then
    Log.warn("Coroutine lags\n" .. debug.traceback())
  end

  if not success then
    if Debug.debug_mode then
      Log.info("Debug error in coroutine")
      Debug.extend_error()
      error(message)
    end
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

local len = function(str)
  return str
    :gsub("<[^>]*>", "")
    :gsub("&.t;", "&")
    :utf_len()
end

common.build_table = function(headers, matrix, needs_shift)
  local new_headers = headers or Fun.range(#matrix[1]):map(function() return "" end):totable()

  local header_sizes = Fun.range(#new_headers)
    :map(function(x)
      return math.max(
        len(new_headers[x]),
        #matrix == 0 and 0 or Fun.range(#matrix)
          :map(function(y) return len(matrix[y][x]) end)
          :max())
    end)
    :totable()

  local total_header = Fun.iter(new_headers)
    :enumerate()
    :map(function(x, h) return tostring(h) .. " " * (header_sizes[x] - len(h)) .. "  " end)
    :reduce(Fun.op.concat, "")

  local text = ""

  if headers then
    text = total_header .. "\n"
      .. (needs_shift and "   " or "")
      .. "-" * (Fun.iter(header_sizes):sum() + 2 * #header_sizes - (needs_shift and 5 or 2))
  end

  for y, row in ipairs(matrix) do
    text = text .. "\n"
    for x, value in ipairs(row) do
      text = text .. tostring(value) .. " " * (header_sizes[x] - len(value) + 2)
    end
  end

  return text
end

common.resolve_path = function(path)
  local result = {}
  for _, part in ipairs(path / "/") do
    if part == ".." then
      table.remove(result)
    else
      table.insert(result, part)
    end
  end
  return table.concat(result, "/")
end

common.load_c_library = function(name)
  for _, path in ipairs({
    "lib/vendor/" .. name,
    love.filesystem.getSource() .. "/lib/vendor/" .. name,
    love.filesystem.getSourceBaseDirectory() .. "/" .. name,
  }) do
    local ok, result = pcall(ffi.load, path)
    Log.info("Loading %s @ %s: %s, %s" % {name, path, ok, result})
    if ok then return result end
  end
end

return common
