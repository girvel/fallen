local html, module_mt, static = Module("tech.texting.html")

local visit, get_availability

html.visit = function(root, args, styles)
  if not styles or not styles.default then
    error("Can not parse HTML without the default style", 2)
  end
  return visit(root, args, styles)
end

visit = function(root, args, styles)
  if type(root) == "string" then
    return {{content = root}}
  end

  if not get_availability(root, args) then return {} end

  local result = (transformers.map[root.name] or transformers.default)(root, nodes, styles)
  return postprocess(root, result, styles)
end

return html
