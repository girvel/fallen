local translation = require("tech.translation")


return Module("state.gui.character_creator.perk_form", function(perk, params)
  if not params.build_options[perk] then
    params.build_options[perk] = 1
  end
  local chosen_option = perk.options[params.build_options[perk]]

  local text = "%s  %s: &lt; %s &gt;\n\n" % {
    params:_get_indicator(params.max_index + 1),
    translation.perks[perk],
    translation.build[perk][chosen_option.codename],
  }

  params.movement_functions[params.max_index + 1] = function(dx)
    params.build_options[perk] = Common.loop(params.build_options[perk] + dx, #perk.options)
  end

  params.max_index = params.max_index + 1
  return text
end)
