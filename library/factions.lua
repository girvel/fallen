local set_faction = function(t, codename, aggressive_towards)
  t[codename] = {
    codename = codename,
    aggressive_towards = aggressive_towards or {},
  }
end

return Static.module("library.factions", function()
  local result = {}
  set_faction(result, "player")
  set_faction(result, "half_orc")
  set_faction(result, "dreamers_detective")
  return result
end)
