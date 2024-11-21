local fun = require("vendor.fun")


local N = 100000
local points = fun.range(N)
  :map(function(i) return {
    math.random() * love.graphics.getWidth(),
    math.random() * love.graphics.getHeight(),
    i / N, i / N, 1, 1,
  } end)
  :totable()

love.draw = function()
  love.graphics.setColor({1, 1, 1})
  love.graphics.points(points)
end
