local translation = require("tech.translation")
local fighter = require("mech.classes.fighter")


return {
  [fighter.fighting_style] = function(params)
    local chosen_style = fighter.fighting_style.options[
      params.build_options[fighter.fighting_style]
    ]
    local text = "%s < %s >\n\n" % {
      params:_get_indicator(params.max_index + 1),
      translation.build[fighter.fighting_style][chosen_style.codename],
    }

    params.max_index = params.max_index + 1
    return text
  end,
}
