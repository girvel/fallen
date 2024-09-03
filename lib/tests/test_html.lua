describe("Html generator", function()
  _G.unpack = table.unpack

  local html = require("lib.html")
  _G.setfenv = function(fn, env)
    local i = 1
    while true do
      local name = debug.getupvalue(fn, i)
      if name == "_ENV" then
        debug.upvaluejoin(fn, i, (function()
          return env
        end), 1)
        break
      elseif not name then
        break
      end

      i = i + 1
    end

    return fn
  end
  _G.unpack = table.unpack
  _G.Table = require("lib.extensions.table")
  _G.Pairs = require("lib.extensions.pairs")
  _G.Module = require("lib.types.module")
  _G.OrderedMap = require("lib.types.ordered_map")

  it("works", function()
    assert.equal(
      '<div class="someclass"><h1>ABC</h1><p><span>A</span>BC</p></div>',
      html(function()
        return div {
          class = "someclass",
          h1 {"ABC"},
          p {span {"A"}, "BC"},
        }
      end)
    )
  end)

  it("handles any types", function()
    local hello = setmetatable({}, {__tostring = function() return "Hello" end})
    assert.equal("<div>Hello</div>", html(function() return div {hello} end))
  end)

  it("handles short tags", function()
    assert.equal("<br/>", html(function() return br() end))
  end)
end)
