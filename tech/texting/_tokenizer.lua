local transformers = require("tech.texting._transformers")


local tokenizer, module_mt, static = Module("tech.texting._tokenizer")

local visit

tokenizer.get_availability = function(root, args)
  local predicate = root.attributes["if"]
  return not predicate or predicate(args)
end

tokenizer.visit = function(root, args, styles)
  if not styles or not styles.default then
    error("Can not parse HTML without the default style", 2)
  end
  return visit(root, args, styles)
end

visit = function(root, args, styles)
  if type(root) == "string" then
    return {{content = root}}
  end

  if not tokenizer.get_availability(root, args) then return {} end

  local nodes = Fun.iter(root.content)
    :map(function(node) return visit(node, args, styles) end)
    :reduce(Table.concat, {})

  return (transformers.map[root.name] or transformers.default)(root, nodes, styles)
end

return tokenizer
