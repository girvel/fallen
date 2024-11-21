--- Library for profiling by lines; all functions marked as deprecated to prevent them leaking into
--- production code.
local line_profiler = {}

local time_spent = {}
local prev_line_i = 0
local prev_t = 0
local target_file, start_line, stop_line

--- @type fun(): number
line_profiler.time_function = os.clock

--- @return nil
line_profiler.start = function()
  local info = debug.getinfo(2, "Sl")
  target_file = info.source
  start_line = info.currentline
  debug.sethook(function(_, new_line_i)
    if debug.getinfo(2, "S").source ~= target_file then return end
    local now = line_profiler.time_function()
    time_spent[prev_line_i] = (time_spent[prev_line_i] or 0) + now - prev_t
    prev_line_i = new_line_i
    prev_t = now
  end, "l")
end

--- @return nil
line_profiler.stop = function()
  stop_line = debug.getinfo(2, "l").currentline
  debug.sethook()
end

--- @return string
line_profiler.report = function()
  if not start_line or not stop_line then return "" end
  local sum = 0
  for i, value in pairs(time_spent) do
    if i > start_line and i < stop_line then
      sum = sum + value
    end
  end

  local report = ""
  for i = start_line + 1, stop_line - 1 do
    local value = time_spent[i] or 0
    report = report .. ("%i\t%.2f s\t%.2f%%\n"):format(
      i, value, value / sum * 100
    )
  end

  return report
end

return line_profiler
