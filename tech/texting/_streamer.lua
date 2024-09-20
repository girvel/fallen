local transformers = require("tech.texting._transformers")


local streamer, module_mt, static = Module("tech.texting._streamer")

local visit

streamer.get_availability = function(root, args)
  local predicate = root.attributes["if"]
  return not predicate or predicate(args)
end

streamer.visit = function(root, args, styles)
  if not styles or not styles.default then
    error("Can not parse HTML without the default style", 2)
  end

  return Fun.iter(visit(root, args, styles))
    :map(function(node) return Table.extend({}, styles.default, node) end)
    :totable()
end

visit = function(root, args, styles)
  if type(root) == "string" then
    return {Table.extend({content = root})}
  end

  if not streamer.get_availability(root, args) then return {} end

  local nodes = Fun.iter(root.content)
    :map(function(node) return visit(node, args, styles) end)
    :reduce(Table.concat, {})

  nodes = (transformers.map[root.name] or transformers.default)(root, nodes, styles)

  local attributes = Table.extend({}, root.attributes)
  attributes["if"] = nil

  for _, node in ipairs(nodes) do
    Table.extend(node, attributes)
  end

  return nodes
end

return streamer
