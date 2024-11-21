-- MODIFIED

--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local inspect = require("vendor.inspect")

local module_mt = {}
local log = setmetatable({ _version = "0.1.0" }, module_mt)

local log_directory = love.filesystem.getSaveDirectory() .. "/logs"
if not love.filesystem.getInfo(log_directory) then
  love.filesystem.createDirectory("/logs")
end

log.usecolor = true
log.outfile = "/logs/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
log.level = "trace"


local levels = {
  trace = {color = "\27[34m", index = 1},
  debug = {color = "\27[36m", index = 2},
  info = {color = "\27[32m", index = 3},
  warn = {color = "\27[33m", index = 4},
  error = {color = "\27[31m", index = 5},
  fatal = {color = "\27[35m", index = 6},
}


local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end


local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, .01)
    end
    if type(x) == "table" then
      x = inspect(x, {depth = 3})
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end


module_mt.__call = function(_, level, trace_shift, ...)
  -- Return early if we're below the log level
  if levels[level].index < levels[log.level].index then
    return ...
  end

  local msg = tostring(...)
  local info = debug.getinfo(2 + trace_shift, "Sl")
  local lineinfo = info.short_src .. ":" .. info.currentline
  local nameupper = level:upper()

  -- Output to console
  print(string.format("%s[%-6s%s]%s %s: %s",
                      log.usecolor and levels[level].color or "",
                      nameupper,
                      os.date("%H:%M:%S"),
                      log.usecolor and "\27[0m" or "",
                      lineinfo,
                      msg))

  -- Output to log file
  if log.outfile then
    love.filesystem.append(
      log.outfile, string.format("[%-6s%s] %s: %s\n", nameupper, os.date(), lineinfo, msg)
    )
  end

  return ...
end

for level, _ in pairs(levels) do
  log[level] = function(...)
    return log(level, 0, ...)
  end
end


return log

