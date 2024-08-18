local utf8 = require("utf8")


local module_mt = {}
local debugx = setmetatable({}, module_mt)


local history = ""
local current_command = ""
local command_history = {}
local _stack

local status = function()
  local result = "STACK:\n"

  for i, data in ipairs(_stack) do
    result = result .. "  %s. %s%s%s\n" % {
      i,
      data.info.short_src,
      data.info.currentline > 0 and ":" .. data.info.currentline or "",
      data.info.name and " :: %s(...)" % data.info.name or "",
    }
  end

  history = history .. result
end

local run = function(command)
  local ok, result = pcall(loadstring(
    "return function(stack) return %s end" % command,
    "shell #" .. #command_history
  ))

  if ok then
    result = table.concat(Fun.iter({pcall(result)})
      :drop_n(1)
      :map(function(x) return Inspect(x) end)
      :totable(), ", ")
  end

  history = history .. "\n" .. result
end

local font = love.graphics.newFont("assets/fonts/clacon2.ttf", 24)

local keypressed = function(scancode)
  if scancode == "backspace" then
    current_command = current_command:sub(
      1, utf8.offset(current_command, utf8.len(current_command)) - 1
    )
  end

  if scancode == "return" then
    history = history .. "\n\n> " .. current_command
    run(current_command)
    table.insert(command_history, current_command)
    current_command = ""
  end

  if scancode == "up" then
    current_command = Fun.iter(command_history)
      :filter(function(c) return c:startsWith(current_command) end)
      :nth(1) or current_command
  end

  if scancode == "d" and (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")) then
    return 0
  end
end

debugx.shell = function()
  if #history == 0 then
    status()
  end

  love.event.pump()
  for name, a,b,c,d,e,f in love.event.poll() do
    if name == "quit" then return 0 end
    if name == "textinput" then
      current_command = current_command .. a
    end
    if name == "keypressed" then
      local result = keypressed(b)
      if result then return result end
    end
  end

  love.graphics.clear()
  love.graphics.printf(
    history .. "\n\n> " .. current_command,
    font, (love.graphics.getWidth() - 800) / 2, 0, 800
  )
  love.graphics.present()
end

debugx.error = function(message, level)
  _stack = {}
  _stack.error_message = message
  love.shell = true
  debugx.extend_error(1)
end

debugx.extend_error = function(level)
  for i = 2 + (level or 0), math.huge do
    local info = debug.getinfo(i)
    if not info then break end
    table.insert(_stack, {
      info = info,
    })
  end
  error(debugx.SIGNAL)
end

debugx.SIGNAL = {}

return debugx
