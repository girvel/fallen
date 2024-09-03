local utf8 = require("utf8")


local stringx = {}

function stringx:utf_sub(a, b)
  return self:sub(utf8.offset(self, a), utf8.offset(self, b + 1) - 1)
end

function stringx:utf_len()
  return utf8.len(self)
end

return stringx
