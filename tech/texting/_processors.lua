local processors, module_mt, static = Module(".mnt.c.Users.widau.Documents.workshop.fallen.tech.texting._processors")


processors.map = {}

local sizeof

processors.map.table = function(root, args, styles, visit)
  local matrix = {}
  local column_sizes = {}

  for _, row in ipairs(root.content) do
    assert(row.name == "tr")
    local matrix_row = {}

    for x, cell in ipairs(row.content) do
      assert(cell.name == "td")
      local children = visit(cell, args, styles)
      column_sizes[x] = math.max(column_sizes[x] or 0, sizeof(children))
      table.insert(matrix_row, children)
    end

    table.insert(matrix, matrix_row)
  end
  Log.trace(Inspect(matrix))

  local result = {}

  for _, row in ipairs(matrix) do
    for y, children in ipairs(row) do
      Table.concat(
        result,
        children,
        {{content = " " * (column_sizes[y] - sizeof(children) + 2)}}
      )
    end
    Table.concat(result, {{content = "\n"}})
  end

  return result
end

processors.default = function(root, args, styles, visit)
  return Fun.iter(root.content)
    :map(function(node) return visit(node, args, styles) end)
    :reduce(Table.concat, {})
end

sizeof = function(children)
  return Fun.iter(children)
    :map(function(c) return c.content:utf_len() end)
    :sum()
end

return processors
