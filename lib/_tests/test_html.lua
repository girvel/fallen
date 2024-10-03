describe("Html generator", function()
  _G.unpack = table.unpack
  _G.Fn = require("lib.essential.fn")
  _G.Keyword = require("lib.essential.keyword")
  _G.Type = require("lib.essential.type")
  _G.Fun = require("lib.vendor.fun")
  _G.Query = require("lib.essential.query")

  local html = require("lib.html")
  local tag = html().tag

  describe("indexing", function()
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

      assert.equal(
        "string",
        type(html.div({{1}}).content[1])
      )
    end)

    it("asserts that it didn't get another tag as an argument", function()
      local success = pcall(html.div, html.div {"Oh hi Mark"})
      assert.is_false(success)
    end)
  end)

  describe("Html().parse", function()
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

    it("can handle void element", function()
      assert.same(
        {
          __type = tag,
          name = "br",
          attributes = {},
          content = {},
        },
        html().parse("<br />")
      )
    end)
  end)

  describe("Html().build_table", function()
    it("builds HTML table from 2d matrix", function()
      assert.same(
        html.table {
          html.tr {
            html.td {"1"}, html.td {"2"},
          },
          html.tr {
            html.td {html.span {"1", "4"}}, html.td {"28"},
          },
        },
        html().build_table {
          {"1", "2"},
          {html.span {"1", tostring(2 + 2)}, "28"}
        }
      )
    end)
  end)

  describe("Tag methods", function()
    local body = html().tag {
      name = "body",
      attributes = {},
      content = {},
    }

    local page = html().tag {
      name = "html",
      attributes = {},
      content = {
        html().tag {
          name = "head",
          attributes = {},
          content = {
            html().tag {
              name = "title",
              attributes = {},
              content = {"Hello, ", "world!"},
            },
          },
        },
        "AAA",
        body,
      },
    }

    it(":find_by_name() searches tag by its name", function()
      assert.equal(body, page:find_by_name("body"))
    end)

    describe(":get_title()", function()
      it("returns page's title", function()
        assert.equal("Hello, world!", page:get_title())
      end)

      it("returns nil if something goes wrong", function()
        assert.equal(nil, body:get_title())
      end)
    end)
  end)
end)
