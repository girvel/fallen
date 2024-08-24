local shaders, _, static = Module("tech.shaders")

shaders.black_and_white = static {
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

shaders.black_and_white_and_red = static {
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
    love.graphics.setColor(entity.creature_flag and Colors.red or Colors.white)
  end,
  deactivate = function(self)
    love.graphics.setColor(Colors.absolute_white)
  end,
}

shaders.latrine = static {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 v = Texel(tex, texture_coords);
      return vec4(v.x, (v.y + 1) / 2, v.z, v.w);
    }
  ]]),
}

shaders.grayscale = static {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 v = Texel(tex, texture_coords);
      float value = (v.x + v.y + v.z) / 3;
      return vec4(value, value, value, v.w);
    }
  ]]),
}

return shaders
