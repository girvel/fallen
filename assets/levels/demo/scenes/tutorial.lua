local shaders = require("tech.shaders")
local api = require("tech.railing").api


return function()
  return {
    {
      name = "Test shaders",
      enabled = true,
      start_predicate = function(self, rails, dt) return true end,

      run = function(self, rails, dt)
        self.enabled = false
        State:set_shader(shaders.black_and_white)
        api.wait_seconds(3)
        State:set_shader(shaders.black_and_white_and_red)
        -- State:set_shader(nil)
      end,
    },
  }
end
