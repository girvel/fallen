local translation = require("tech.translation")


return Module("state.gui.character_creator.perk_form", function(choice, params)
  if not params.build_options[choice] then
    params.build_options[choice] = 1
  end
  local chosen_option = choice.options[params.build_options[choice]]

  local text = '%s  %s: &lt; <span tooltip="%s">%s</span> &gt;\n\n' % {
    params:_get_indicator(params.max_index + 1),
    translation.perks[choice],
    chosen_option.codename,
    translation.build[choice][chosen_option.codename],
  }

  params.movement_functions[params.max_index + 1] = function(dx)
    params.build_options[choice] = Common.loop(params.build_options[choice] + dx, #choice.options)
  end

  params.max_index = params.max_index + 1
  return text
end)
