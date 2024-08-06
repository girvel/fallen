local shaders = Static.module("tech.shaders")

shaders.black_and_white = Static {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 v = Texel(tex, texture_coords);
      if (v.x < 0.2 && v.y < 0.2 && v.z < 0.2) {
        return vec4(0.0);
      }
      return vec4(0.93, 0.93, 0.93, 1.0);
    }
  ]]),
}

shaders.black_and_white_and_red = Static {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 v = Texel(tex, texture_coords);
      if (v.x < 0.2 && v.y < 0.2 && v.z < 0.2) {
        return vec4(0.0);
      }
      return color;
    }
  ]]),
  preprocess = function(self, entity)
    love.graphics.setColor(Common.hex_color(entity.creature_flag and "e64e4b" or "ededed"))
  end,
  deactivate = function(self)
    love.graphics.setColor({1, 1, 1})
  end,
}

return shaders
