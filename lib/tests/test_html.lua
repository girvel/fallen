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

  -- _G.Table = require("lib.extensions.table")
  -- _G.Pairs = require("lib.extensions.pairs")
  -- _G.Module = require("lib.types.module")
  -- _G.OrderedMap = require("lib.types.ordered_map")

  it("generates an internal representation tree", function()
    local tag = html().tag
    assert.equal(
      {
        __type = tag,
        tag = "div",
        attributes = {
          class = "someclass",
        },
        content = {
          {
            __type = tag,
            tag = "h1",
            attributes = {},
            content = {"ABC"},
          },
          {
            __type = tag,
            tag = "p",
            attributes = {},
            content = {
              {
                __type = tag,
                tag = "span",
                attributes = {},
                content = {"A"},
              },
              "BC",
            },
          },
        },
      },
      html.div {
        class = "someclass",
        html.h1 {"ABC"},
        html.p {html.span{"A"}, "BC"},
      }
    )
  end)

  it("can handle attributes of any type, but the content is converted to string", function()
    local hello = setmetatable({}, {__tostring = function() return "Hello" end})
    local f = function() end
    assert.same(
      {
        __type = html().tag,
        tag = "div",
        attributes = {
          integer = 1,
          boolean = true,
          fn = f,
          table = hello,
        },
        content = {
          "Hello",
          "based",
        },
      },
      html.div {
        class = "based",
        integer = 1,
        boolean = true,
        fn = f,
        table = hello,
        hello,
        "based",
      }
    )
  end)

  it("can parse HTML", function()
    local tag = html().tag
    assert.same(
      {
        __type = tag,
        tag = "div",
        attributes = {class = "a"},
        content = {
          "Hello, ",
          {
            __type = tag,
            tag = "span",
            attributes = {},
            content = {"world"},
          },
          "!",
        },
      },
      html().parse('<div class="a">Hello, <span>world</span>!</div>')
    )
  end)

  -- TODO! it can convert attribute types
end)
