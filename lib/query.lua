local module_mt = {}
local query = setmetatable({}, module_mt)

module_mt.__call = function(_, subject)
  return setmetatable({
    _query_subject = subject,
  }, {
    __index = function(self, index)
      if index == "_query_subject" then return rawget(self, "_query_subject") end
      return query(self._query_subject ~= nil and self._query_subject[index] or nil)
    end,
    __call = function(self, head, ...)
      if head._query_subject then
        head = head._query_subject
      end
      return query(self._query_subject ~= nil and self._query_subject(head, ...) or nil)
    end,
    __unm = function(self)
      return self._query_subject
    end,
  })
end

return query