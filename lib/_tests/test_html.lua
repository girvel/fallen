describe("Html generator", function()
  _G.unpack = table.unpack
  _G.Fn = require("lib.essential.fn")
  _G.Keyword = require("lib.essential.keyword")  -- TODO! too
  _G.Type = require("lib.essential.type")  -- TODO! type is in essentials/

  local html = require("lib.html")
  local tag = html().tag

  it("generates an internal representation tree", function()
    assert.same(
      {
        __type = tag,
        name = "div",
        attributes = {
          class = "someclass",
        },
        content = {
          {
            __type = tag,
            name = "h1",
            attributes = {},
            content = {"ABC"},
          },
          {
            __type = tag,
            name = "p",
            attributes = {},
            content = {
              {
                __type = tag,
                name = "span",
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
        __type = tag,
        name = "div",
        attributes = {
          class = "based",
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
    assert.same(
      {
        __type = tag,
        name = "div",
        attributes = {class = "a"},
        content = {
          "Hello, ",
          {
            __type = tag,
            name = "span",
            attributes = {},
            content = {"world"},
          },
          "!",
        },
      },
      html().parse('<div class="a">Hello, <span>world</span>!</div>')
    )
  end)

  it("can convert attributes to appropriate types", function()
    assert.same(
      {
        __type = tag,
        name = "div",
        attributes = {id = 3},
        content = {
          {
            __type = tag,
            name = "span",
            attributes = {hidden = true},
            content = {},
          }
        },
      },
      html().parse(
        '<div id="3"><span hidden="true"></span></div>',
        {
          id = tonumber,
          hidden = function(string)
            assert(string == "true" or string == "false")
            return string == "true"
          end,
        }
      )
    )
  end)

  it("can handle empty tag", function()
    assert.same(
      {
        __type = tag,
        name = "div",
        attributes = {},
        content = {},
      },
      html().parse("<div></div>")
    )
  end)

  -- TODO! handling br/
end)
