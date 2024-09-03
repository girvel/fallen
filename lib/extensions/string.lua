local utf8 = require("utf8")


local stringx = {}

stringx.utf_sub = function(str, a, b)
  if not b then
    b = stringx.utf_len(str)
  elseif b < 1 then
    b = b + stringx.utf_len(str)
  end
  return str:sub(utf8.offset(str, a), utf8.offset(str, b + 1) - 1)
end

stringx.utf_len = function(str)
  return utf8.len(str)
end

return stringx
