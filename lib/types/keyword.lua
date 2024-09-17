local keyword = function(_, f)
  assert(type(f) == "function")
  return setmetatable({}, {
    __call = function(...) return f(...) end,
    __concat = function(...) return f(...) end,
  })
end

return keyword(nil, keyword)
