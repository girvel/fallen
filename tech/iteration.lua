local iteration, module_mt, static = Module("tech.iteration")

--- @param radius? integer
--- @return fun(): vector
iteration.expanding_rhombus = function(radius)
  local coroutine_based_iterator = function()
    coroutine.yield(Vector.zero)

    for r = 1, radius or 100 do
      for x = 0, r - 1 do
        coroutine.yield(Vector {x, x - r})
      end

      for x = r, 1, -1 do
        coroutine.yield(Vector {x, r - x})
      end

      for x = 0, 1 - r, -1 do
        coroutine.yield(Vector {x, x + r})
      end

      for x = -r, 1 do
        coroutine.yield(Vector {x, -r - x})
      end
    end
  end

  --- @type fun(): vector
  return setmetatable({inner = coroutine.create(coroutine_based_iterator)}, {__call = function(self)
    if coroutine.status(self.inner) == "dead" then return nil end
    return Common.resume_logged(self.inner)
  end})
end

return iteration
