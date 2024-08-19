local utf8 = require("utf8")


local module_mt = {}
local debugx = setmetatable({}, module_mt)


local history = ""
local current_command = ""
local command_history = {}
local stack_index = 1
local _stack = {}
local render_offset = 0

local status = function()
  local result = "\nERROR: %s\n\nSTACK:\n" % Inspect(_stack.error_message)

  for i, data in ipairs(_stack) do
    result = result .. "%s %s. %s%s%s\n" % {
      i == stack_index and "-" or " ",
      i,
      data.info.short_src,
      data.info.currentline < 0 and "" or ":" .. data.info.currentline,
      not data.info.name and "" or " :: %s(...)" % {
        data.info.name,
      },
    }
  end

  result = result .. "\nLOCALS:\n"

  for i, data in ipairs(_stack[stack_index].locals) do
    result = result .. "  %s = %s\n" % {
      data.name, Common.indent(Inspect(data.value, {depth = 1, keys_limit = 5})):sub(3),
    }
  end

  history = history .. result
end

local cd = function(i)
  if _stack[i] then stack_index = i end
  status()
end

local clear = function()
  history = ""
end

local run = function(command)
  local ok, result
  for _, form in ipairs({"return ", ""}) do
    ok, result = pcall(loadstring(
      "return function(cd, clear%s) %s%s end" % {
        Fun.iter(_stack[stack_index].locals)
          :map(function(pair) return ", " .. pair.name end)
          :reduce(Fun.op.concat, ""),
        form,
        command,
      },
      "shell #" .. #command_history
    ))
    if ok then break end
  end

  if ok then
    result = table.concat(Fun.iter({pcall(result, cd, clear, unpack(
      Fun.iter(_stack[stack_index].locals)
        :map(function(pair) return pair.value end)
        :totable()
    ))})
      :drop_n(1)
      :map(function(x) return Inspect(x) end)
      :totable(), ", ")
  end

  if #result > 0 then
    history = history .. "\n" .. result
  end
end

local font = love.graphics.newFont("assets/fonts/clacon2.ttf", 24)

local keypressed = function(scancode)
  if scancode == "backspace" then
    current_command = current_command:sub(
      1, utf8.offset(current_command, utf8.len(current_command)) - 1
    )
  end

  if scancode == "return" then
    local new_history_i = #history
    history = history .. "\n\n> " .. current_command
    run(current_command)
    table.insert(command_history, current_command)
    current_command = ""
    render_offset = render_offset - Fun.iter(history:sub(new_history_i))
      :filter(function(c) return c == "\n" end)
      :map(function() return 1 end)
      :sum()
  end

  if scancode == "up" then
    current_command = Fun.iter(command_history)
      :filter(function(c) return c:startsWith(current_command) end)
      :reduce(Fun.op.land, current_command)
  end

  if scancode == "d" and (love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")) then
    return 0
  end

  if scancode == "pageup" then
    render_offset = render_offset + love.graphics.getHeight() / font:getHeight()
  end

  if scancode == "pagedown" then
    render_offset = render_offset - love.graphics.getHeight() / font:getHeight()
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
    if name == "wheelmoved" then
      render_offset = render_offset + b * 3
    end
  end

  love.graphics.clear()
  love.graphics.printf(
    history .. "\n\n> " .. current_command,
    font, (love.graphics.getWidth() - 1000) / 2, render_offset * font:getHeight(), 1000
  )
  love.graphics.present()
end

debugx.handle_error = function(msg)
  debugx.extend_error({level = 2})
  _stack.error_message = msg
  return debugx.shell
end

debugx.extend_error = function(args)
  args = args or {}
  for i = 2 + (args.level or 0), math.huge do
    local info
    if args.thread then
      info = debug.getinfo(args.thread, i)
    else
      info = debug.getinfo(i)
    end
    if not info then break end

    local locals = {}
    for j = 1, math.huge do
      local k, v = debug.getlocal(i, j)
      if not k then break end
      table.insert(locals, {name = k, value = v})
    end

    table.insert(_stack, {
      info = info,
      locals = locals,
    })
  end
end

debugx.SIGNAL = {}

return debugx
