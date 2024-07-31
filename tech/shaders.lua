local shaders = {}

shaders.black_and_white = {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 texturecolor = Texel(tex, texture_coords);
      if (texturecolor.xyz == vec3(0.0)) {
        return vec4(0.0);
      }
      return vec4(0.93, 0.93, 0.93, 1.0);
    }
  ]])
}

return shaders
