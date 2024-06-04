local module = {}

module.wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/wall.png"),
    },
  }
end

module.planks = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/planks.png")
    }
  }
end

module.grass = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/grass.png")
    }
  }
end

module.smooth_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  }
end

module.crooked_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/crooked_wall.png")
    }
  }
end

return module
