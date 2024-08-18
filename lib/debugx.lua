local utf8 = require("utf8")


local module_mt = {}
local debugx = setmetatable({}, module_mt)

local history = "Hello, world!"
local command_history = {}

local stack = function()
  history = history .. "\n" .. debug.traceback()
end

local run = function(command)
  local ok, result = pcall(loadstring(
    "return function(stack) return %s end" % command,
    "shell #" .. #command_history
  ))
  if ok then
    result = table.concat(Fun.iter({pcall(result, stack)})
      :drop_n(1)
      :map(function(x) return Inspect(x) end)
      :totable(), ", ")
  end

  history = history .. "\n" .. result
end

local font = love.graphics.newFont("assets/fonts/clacon2.ttf", 24)
local current_command = ""

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

return debugx
