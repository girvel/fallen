local parse, module_mt, static = Module("tech.texting.parse")

local parse_event, parse_expression

module_mt.__call = function(_, raw_html)
  return Html().parse(raw_html, {
    color = Colors.from_hex,
    on_hover = parse_event("on_hover"),
    on_click = parse_event("on_click"),
    on_update = parse_event("on_update"),
    ["if"] = parse_expression("if"),
  })
end

parse_event = function(event_name)
  return function(string)
    local f, err = loadstring(
      "return function(self)\n%s\nend" % string:gsub("&gt;", ">"):gsub("&lt;", "<")
    )()
    if f then return f end
    Log.error("Error loading %s attribute\n%s\n%s" % {event_name, err})
  end
end

parse_expression = function(event_name)
  return function(string)
    return function(args)
      local f, err = loadstring(
        [[
          return function(args)
            %s
            return %s
          end
        ]] % {
          Fun.iter(args)
            :map(function(name) return "local %s = args.%s\n" % {name, name} end)
            :reduce(Fun.op.concat, ""),
          string,
        }
      )

      if f then return f()(args) end
      Log.error("Error loading %s attribute\n%s\n%s" % {event_name, err, string})
    end
  end
end

return parse
