local shaders, _, static = Module("tech.shaders")

--- @class shader
--- @field love_shader love.Shader
--- @field preprocess? fun(self: shader, entity: entity): nil
--- @field deactivate? fun(self: shader): nil

--- @type shader
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

--- @type shader
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
    love.graphics.setColor(entity.creature_flag and Colors.red() or Colors.white())
  end,
  deactivate = function(self)
    love.graphics.setColor(Colors.absolute_white())
  end,
}

--- @type shader
shaders.latrine = static {
  love_shader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 v = Texel(tex, texture_coords);
      vec4 u = vec4(0.376, 0.702, 0.494, v.w);
      return vec4(
        (v.xyz + u.xyz) / 2,
        v.w
      );
    }
  ]]),
}

--- @type shader
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

-- Can be refactored to serializable(love.graphics.newShader)
shaders._charmed = static {inner = love.graphics.newShader [[
  uniform bool is_charmer;

  vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
  {
    vec4 v = Texel(tex, texture_coords);
    if (is_charmer) return v;
    return vec4(v.xyz / 3, v.w);
  }
]]}

--- @param by table[] list of entities not affected by shader
--- @return shader
shaders.charmed = function(by)
  return {
    love_shader = shaders._charmed.inner,
    preprocess = function(self, entity)
      self.love_shader:send("is_charmer", Table.contains(by, entity))
    end,
  }
end

--- @type shader
shaders.reflective = static {
  love_shader = love.graphics.newShader [[
    uniform bool reflects;
    uniform Image reflection;

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 it = Texel(tex, texture_coords);
      vec4 other;
      if (reflects && it == vec4(0., 0., 1. / 255, 1.)) {
        other = Texel(reflection, texture_coords);
        if (other.a == 0.) return vec4(0., 0., 0., 1.);
        return other;
      }
      return it;
    }
  ]],

  _get_reflection_image_data = function(self, entity)
    assert(entity.reflection_vector, "reflective shader requires `.reflection_vector` field")

    local reflected = State.grids.solids:safe_get(entity.position + entity.reflection_vector)
    if not reflected or not reflected.animation then return end

    local codename = reflected.animation.current.codename
    local has_direction = false
    for _, direction_name in ipairs(Vector.direction_names) do
      if codename:ends_with(direction_name) then
        codename = codename:sub(1, #codename - #direction_name - 1)
        has_direction = true
        break
      end
    end

    if not has_direction then return end

    local reflected_direction = Vector[reflected.direction]
    local is_parallel = (entity.reflection_vector[1] == 0) == (reflected_direction[1] == 0)
    local reflection_direction_name = Vector.name_from_direction(
      (is_parallel and -1 or 1) * reflected_direction
    )

    local animation = reflected.animation.pack["%s_%s" % {codename, reflection_direction_name}]

    local frame = animation[math.min(math.floor(reflected.animation.frame), #animation)]
    if not frame then return end

    return frame.image
  end,

  preprocess = function(self, entity)
    local image_data = self:_get_reflection_image_data(entity)
    self.love_shader:send("reflects", image_data ~= nil)
    if not image_data then return end
    self.love_shader:send("reflection", image_data)
  end,
}

return shaders
