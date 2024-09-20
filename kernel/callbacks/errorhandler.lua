return function(msg)
  Log.fatal(debug.traceback("Error: " .. tostring(msg), 2):gsub("\n[^\n]+$", ""))
  love.window.requestAttention()
  if Debug.debug_mode then
    return Debug.handle_error(msg)
  end
end
