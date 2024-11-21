return function(repr)
  return setmetatable({}, {
    __tostring = function() return tostring(repr) end,
  })
end
