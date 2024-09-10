local mech, _, static = Module("mech")

mech.experience_for_level = static {
  [0] = -1,
  0, 300, 900, 2700, 6500,
}

mech.get_progression = function(holder, level)
  return Fun.iter(holder.progression_table)
    :take_n(level)
    :reduce(Table.concat, {})
end

return mech
