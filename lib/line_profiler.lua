--- Library for profiling by lines; all functions marked as deprecated to prevent them leaking into
--- production code.
local line_profiler = {}

local time_spent = {}
local prev_line_i = 0
local prev_t = 0
local target_file, start_line, stop_line

--- @return nil
--- @deprecated
line_profiler.start = function()
  local info = debug.getinfo(2, "Sl")
  target_file = info.source
  start_line = info.currentline
  debug.sethook(function(_, new_line_i)
    if debug.getinfo(2, "S").source ~= target_file then return end
    local now = love.timer.getTime()
    time_spent[prev_line_i] = (time_spent[prev_line_i] or 0) + now - prev_t
    prev_line_i = new_line_i
    prev_t = now
  end, "l")
end

--- @return nil
--- @deprecated
line_profiler.stop = function()
  stop_line = debug.getinfo(2, "l").currentline
  debug.sethook()
end

--- @return string
--- @deprecated
line_profiler.report = function()
  local sum = 0
  for i, value in pairs(time_spent) do
    if i > 0 then
      sum = sum + value
    end
  end

  local report = ""
  for i = start_line, stop_line do
    local value = time_spent[i] or 0
    report = report .. ("%i\t%.2f s\t%.2f%%\n"):format(
      i, value, value / sum * 100
    )
  end

  return report
end

return line_profiler
