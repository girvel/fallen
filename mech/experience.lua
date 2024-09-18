local experience, module_mt, static = Module("mech.experience")

experience.for_level = static {
  [0] = -1,
  0, 300, 900, 2700, 6500,
}

experience.get_progression = function(holder, level)
  return Fun.iter(holder.progression_table)
    :take_n(level)
    :reduce(Table.concat, {})
end

experience.get_proficiency_modifier = function(level)
  return 1 + math.ceil(level / 4)
end

experience.get_level = function(xp)
  return Fun.iter(experience.for_level)
    :enumerate()
    :filter(function(level, exp) return exp <= xp end)
    :map(function(level, exp) return level end)
    :max() or 0

end

return experience