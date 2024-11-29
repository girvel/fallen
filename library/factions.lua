local set_faction = function(t, codename, aggressive_towards)
  t[codename] = {
    codename = codename,
    aggressive_towards = aggressive_towards or {},
  }
end

return Module("library.factions", function()
  local result = {}
  set_faction(result, "player")
  set_faction(result, "half_orc")
  set_faction(result, "dreamers_detective")
  set_faction(result, "monster", {player = true})
  set_faction(result, "guards")
  set_faction(result, "canteen_killers")

  for i = 1, 2 do
    set_faction(result, "dreamers_" .. i)
  end
  return result
end)
