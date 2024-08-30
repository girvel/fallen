local html_index = function(_, key)
  return function(t)
    if t == nil then return ("<%s/>"):format(key) end

    local attributes = ""
    for k, v in pairs(t) do
      if type(k) == "string" then
        attributes = attributes .. (' %s=%q'):format(k, tostring(v))
      end
    end

    local content = ""
    for _, v in ipairs(t) do
      content = content .. tostring(v)
    end

    return ("<%s%s>%s</%s>"):format(key, attributes, content, key)
  end
end

return function(html_factory)
  setfenv(html_factory, setmetatable(Table.extend({}, _G), {__index = html_index}))
  return html_factory()
end
