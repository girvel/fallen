local processors, module_mt, static = Module("tech.texting._processors")


processors.map = static {}

local sizeof, tline

processors.map.table = function(root, args, styles, visit)
  local matrix = {}
  local column_sizes = {}

  for _, row in ipairs(root.content) do
    assert(row.name == "tr")
    local matrix_row = {}

    for x, cell in ipairs(row.content) do
      if cell.name == "tline" then
        table.insert(matrix_row, tline)
      elseif cell.name == "td" then
        local children = visit(cell, args, styles)
        column_sizes[x] = math.max(column_sizes[x] or 0, sizeof(children))
        table.insert(matrix_row, children)
      else
        error()
      end
    end

    table.insert(matrix, matrix_row)
  end

  local result = {}

  for _, row in ipairs(matrix) do
    for y, children in ipairs(row) do
      if children == tline then
        table.insert(result, {
          content = "-" * (Fun.iter(column_sizes)
            :drop_n(y - 1)
            :map(function(n) return n + 2 end)
            :sum() - 2)
        })
      else
        Table.concat(
          result,
          children,
          {{content = " " * (column_sizes[y] - sizeof(children) + 2)}}
        )
      end
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

tline = {}

return processors
