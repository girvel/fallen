local query, query_mt

--- @class Query: { [string]: Query | any }
--- @operator call: Query
--- @operator unm: any

query_mt = {
  __unm = function(self)
    return rawget(self, "inner")
  end,

  __index = function(self, index)
    local inner = -self
    local inner_type = type(inner)

    if inner_type == "table" or inner_type == "string" then
      return query(inner[index])
    end

    return query(nil)
  end,

  __newindex = function(self, index, new_value)
    local inner = -self
    if type(inner) ~= "table" then return end
    inner[index] = new_value
  end,

  __call = function(self, head, ...)
    if getmetatable(head) == query_mt then
      head = -head
    end

    local inner = -self
    if type(inner) == "function" or -query(getmetatable(inner)).__call then
      return query(inner(head, ...))
    end
    return query(nil)
  end,
}

--- Monad for nil-conditional indexing
--- Allows for queries like `-Query(some_table).field.subfield`
--- @see test_query
--- @param value any
--- @return Query
query = function(value)
  return setmetatable({inner = value}, query_mt)
end

local a = -query().a.b.c.d.e

return query

-- local query
-- 
-- local qlength = function(self)
--   return query(self._query_subject ~= nil and #self._query_subject or nil)
-- end
-- 
-- query = function(subject)
--   return setmetatable({
--     _query_subject = subject,
--   }, {
--     __index = function(self, index)
--       if index == "_query_subject" then return rawget(self, "_query_subject") end
--       if index == "qlength" then return qlength end
--       local subject_type = type(self._query_subject)
--       return query(
--         (subject_type == "string" or subject_type == "table")
--           and self._query_subject[index]
--           or nil
--       )
--     end,
-- 
--     __newindex = function(self, index, value)
--       if index == "_query_subject" then rawset(self, "_query_subject", value) end
--       if type(self._query_subject) ~= "table" then return end
--       self._query_subject[index] = value
--     end,
-- 
--     __call = function(self, head, ...)
--       if type(head) == "table" and head._query_subject then
--         head = head._query_subject
--       end
--       if type(self._query_subject) == "function"
--         or -query(getmetatable(self._query_subject)).__call
--       then
--         return query(self._query_subject(head, ...))
--       end
--       return query(nil)
--     end,
-- 
--     __unm = function(self)
--       return self._query_subject
--     end,
--   })
-- end
-- 
-- return query
