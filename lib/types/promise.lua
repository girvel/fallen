local promise, module_mt, static = Module("lib.types.promise")

local promise_methods = {}
local promise_mt = {__index = promise_methods}

module_mt.__call = function()
  return setmetatable({
    queue = {},
  }, promise_mt)
end

promise_methods.next = function(self, callback)
  table.insert(self.queue, callback)
  return self
end

promise_methods.resolve = function(self, ...)
  local args = {...}
  for _, callback in ipairs(self.queue) do
    args = {callback(unpack(args))}
  end
  return unpack(args)
end

return promise
