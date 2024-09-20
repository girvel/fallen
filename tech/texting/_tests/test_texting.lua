local lust = require("lib.vendor.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect
-- TODO! automate integration tests
-- TODO! clean up or create a task for serialization tests


describe("Text entities generation facade", function()
  local texting = require("tech.texting")

  describe("(stage 1)", function()
    it("(stage 1) can parse raw HTML with changing attribute types", function()
      local node = texting.parse('<div color="ffffff" if="true" on_hover="State = nil"></div>')
      expect(node.name).to.be("div")
      expect(node.content).to.equal({})
      expect(node.attributes.color).to.equal({1, 1, 1})
      expect(type(node.attributes["if"])).to.be("function")
      expect(type(node.attributes.on_hover)).to.be("function")
    end)
  end)

  describe("(stage 2)", function()
    local streamer = require("tech.texting._streamer")
    local styles = {default = {}}

    it("can turn html-based tree into the stream of text pieces", function()
      local node = Html.div {
        "Hello, ",
        Html.span {
          "world!",
        }
      }

      local stream = streamer.visit(node, {}, styles)

      expect(stream).to.equal({{content = "Hello, "}, {content = "world!"}})
    end)

    it("can do styling", function()
      local stream = streamer.visit(
        Html.div {
          "Hello, ",
          Html.large {"world!"},
        },
        {},
        {
          default = {font_size = 12},
          large = {font_size = 18},
        }
      )

      expect(stream).to.equal({
        {content = "Hello, ", font_size = 12},
        {content = "world!", font_size = 18},
      })
    end)

    it("can do built-in HTML tags", function()
      local stream = streamer.visit(
        Html.h1 {"Oh hi Mark"},
        {},
        {default = {}, h1 = {font_size = 30}, h1_prefix = {color = {0, 0, 0}}}
      )

      expect(stream).to.equal({
        {content = "# ", font_size = 30, color = {0, 0, 0}},
        {content = "Oh hi Mark", font_size = 30},
        {content = "\n\n"},
      })
    end)

    it("can skip some data conditionally", function()
      local node = Html.div {
        "Hello, ",
        Html.span {
          ["if"] = function(args) return args.global end,
          "world!",
        },
        Html.span {
          ["if"] = function(args) return not args.global end,
          "player.",
        },
      }

      expect(streamer.visit(node, {global = true}, styles))
        .to.equal({{content = "Hello, "}, {content = "world!"}})

      expect(streamer.visit(node, {global = false}, styles))
        .to.equal({{content = "Hello, "}, {content = "player."}})
    end)
  end)
end)
