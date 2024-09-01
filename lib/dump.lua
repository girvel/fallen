local module_mt = {}
local dump = setmetatable({}, module_mt)


local to_expression = function(statement)
  return ("(function()\n%s\nend)()"):format(statement)
end

local handle_primitive
local stack, warnings
local allowed_big_upvalues = {}


dump.get_warnings = function() return {unpack(warnings)} end
dump.ignore_upvalue_size = setmetatable({}, {
  __concat = function(self, other)
    return self(other)
  end,
  __call = function(self, other)
    allowed_big_upvalues[other] = true
    return other
  end,
})
dump.require_path = nil
dump.serializers = {}


local build_table = function(x, cache)
  cache.size = cache.size + 1
  cache[x] = cache.size

  local mt = getmetatable(x)

  local serialized
  if dump.serializers[x] then
    serialized = dump.serializers[x](x)
  elseif mt and mt.__serialize then
    serialized = mt.__serialize(x)
  end

  local result = {}
  if serialized then
    if type(serialized) == "function" then
      allowed_big_upvalues[serialized] = true
      table.insert(result, ("local _ = %s()"):format(handle_primitive(serialized, cache)))
    end
    if type(serialized) == "string" then
      table.insert(result, "local _ = " .. serialized)
    end
  else
    table.insert(result, "local _ = {}")
    table.insert(result, ("cache[%s] = _"):format(cache.size))
    if mt then
      table.insert(result, ("setmetatable(_, %s)"):format(handle_primitive(mt, cache)))
    end

    for k, v in pairs(x) do
      table.insert(stack, tostring(k))
      table.insert(result, ("_[%s] = %s"):format(
        handle_primitive(k, cache),
        handle_primitive(v, cache)
      ))
      table.remove(stack)
    end
  end

  if dump.serializers[x] then
    table.insert(result, ("dump.serializers[_] = %s"):format(
      handle_primitive(dump.serializers[x], cache)
    ))
  end

  table.insert(result, "return _")
  return table.concat(result, "\n")
end

local build_function = function(x, cache)
  cache.size = cache.size + 1
  cache[x] = cache.size

  local result = {}

  local ok, res = pcall(string.dump, x)

  if not ok then
    error("Unable to dump function " .. table.concat(stack, "."))
  end

  result[1] = "local _ = " .. ([[load(%q)]]):format(res)
  result[2] = ("cache[%s] = _"):format(cache.size)

  if allowed_big_upvalues[x] then
    result[3] = "dump.ignore_upvalue_size(_)"
  end

  for i = 1, math.huge do
    local k, v = debug.getupvalue(x, i)
    if not k then break end

    table.insert(stack, ("<upvalue %s>"):format(k))
    local upvalue = handle_primitive(v, cache)
    table.remove(stack)

    if not allowed_big_upvalues[x] and #upvalue > 2048 then
      table.insert(warnings, ("Big upvalue %s in %s"):format(k, table.concat(stack, ".")))
    end
    table.insert(result, ("debug.setupvalue(_, %s, %s)"):format(i, upvalue))
  end
  table.insert(result, "return _")
  return table.concat(result, "\n")
end

local primitives = {
  number = function(x)
    return tostring(x)
  end,
  string = function(x)
    return string.format("%q", x)
  end,
  ["function"] = function(x, cache)
    return to_expression(build_function(x, cache))
  end,
  table = function(x, cache)
    return to_expression(build_table(x, cache))
  end,
  ["nil"] = function()
    return "nil"
  end,
  boolean = function(x)
    return tostring(x)
  end,
}

handle_primitive = function(x, cache)
  local xtype = type(x)
  assert(primitives[xtype], ("dump does not support type %q of %s"):format(xtype, table.concat(stack, ".")))

  if xtype == "table" or xtype == "function" then
    local cache_i = cache[x]
    if cache_i then
      return ("cache[%s]"):format(cache_i)
    end
  end

  return primitives[xtype](x, cache)
end

module_mt.__call = function(self, x)
  assert(
    self.require_path,
    "Put the lua path to dump libary into dump.require_path before calling dump itself"
  )

  stack = {}
  warnings = {}
  local cache = {size = 0}
  local result
  if type(x) == "table" then
    result = build_table(x, cache)
  else
    result = "return " .. handle_primitive(x, cache)
  end

  return ("local cache = {}\nlocal dump = require(\"%s\")\n"):format(self.require_path) .. result
end

return dump
