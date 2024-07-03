local module = {}

module.get_modifier = function(ability_score)
  return math.floor((ability_score - 10) / 2)
end

module.abilities = function(str, dex, con, int, wis, cha)
  return {
    strength = str,
    dexterity = dex,
    constitution = con,
    intelligence = int,
    wisdon = wis,
    charisma = cha,
  }
end

module.are_hostile = function(first, second)
  return (first.faction or second.faction) and first.faction ~= second.faction
end

return module
