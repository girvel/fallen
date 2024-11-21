local utf8 = require("utf8")


local methods = {}

methods.utf_sub = function(str, a, b)
  if not b then
    b = methods.utf_len(str)
  elseif b < 1 then
    b = b + methods.utf_len(str) + 1
  end
  return str:sub(utf8.offset(str, a), utf8.offset(str, b + 1) - 1)
end

methods.utf_len = function(str)
  return utf8.len(str)
end

local ru_lower = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
local ru_upper = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"

methods.utf_lower = function(str)
  str = str:lower()
  for i = 1, methods.utf_len(ru_lower) do
    str = str:gsub(
      methods.utf_sub(ru_upper, i, i),
      methods.utf_sub(ru_lower, i, i)
    )
  end
  return str
end

methods.utf_upper = function(str)
  str = str:upper()
  for i = 1, methods.utf_len(ru_lower) do
    str = str:gsub(
      methods.utf_sub(ru_lower, i, i),
      methods.utf_sub(ru_upper, i, i)
    )
  end
  return str
end

methods.starts_with = function(str, prefix)
  return str:sub(1, #prefix) == prefix
end

methods.ends_with = function(str, suffix)
  return str:sub(-#suffix, -1) == suffix
end

methods.split = function(str, pat, plain)
  local t = {}

  while true do
    local pos1, pos2 = str:find(pat, 1, plain or false)

    if not pos1 or pos1 > pos2 then
      t[#t + 1] = str
      return t
    end

    t[#t + 1] = str:sub(1, pos1 - 1)
    str = str:sub(pos2 + 1)
  end
end

methods.ljust = function(str, int, padstr)
  local len = utf8.len(str)

  if int > len then
    local num = padstr and math.floor((int - len) / #padstr) or int - len
    str = str .. (padstr or " ") * num
    len = #str
    if len < int then str = str .. padstr:sub(1, int - len) end
  end

  return str
end

methods.rjust = function(str, int, padstr)
  local len = #str

  if int > len then
    local num = padstr and math.floor((int - len) / #padstr) or int - len
    str = ((padstr or " ") * num) .. str
    len = #str
    if len < int then str = padstr:sub(1, int - len) .. str end
  end

  return str
end

methods.lstrip = function(str)
  return str:gsub("^%s+", "")
end

methods.rstrip = function(str)
  return str:gsub("%s+$", "")
end

methods.strip = function(str)
  return methods.rstrip(methods.lstrip(str))
end

methods.indent = function(str)
  return table.concat(Fun.iter(str / "\n")
    :map(function(line) return "  " .. line end)
    :totable(), "\n")
end


local mt = {}

mt.__mul = function(a, b)
  return a:rep(b)
end

mt.__div = function(a, b)
  return methods.split(a, b, true)
end

mt.__mod = function(a, b)
   if type(b) == "table" then
      return a:format(unpack(b))
   else
      return a:format(b)
   end
end


return {
  inject = function(target_metatable)
    for k, v in pairs(mt) do
      target_metatable[k] = v
    end

    for k, v in pairs(methods) do
      target_metatable.__index[k] = v
    end
  end
}
