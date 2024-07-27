local translation = require("tech.translation")


return function(perk, params)
  local chosen_style = perk.options[
    params.build_options[perk]
  ]

  local text = "%s %s: < %s >\n\n" % {
    params:_get_indicator(params.max_index + 1),
    translation.perks[perk],
    translation.build[perk][chosen_style.codename],
  }

  params.movement_functions[params.max_index + 1] = function(dx)
    params.build_options[perk] =
      (params.build_options[perk] + dx - 1) % #perk.options + 1
  end

  params.max_index = params.max_index + 1
  return text
end
