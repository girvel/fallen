local lust = require("lib.vendor.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect
-- TODO! automate integration tests
-- TODO! clean up serialization tests

local sprite = require("tech.sprite")


describe("Text entities generation process", function()
  describe("(stage 1)", function()
    local parse = require("tech.texting._parse")

    it("(stage 1) can parse raw HTML with changing attribute types", function()
      local node = parse('<div color="ffffff" if="true" on_hover="State = nil"></div>')
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

  describe("(stage 3)", function()
    local wrap = require("tech.texting._wrap")

    it("can wrap text", function()
      local w = 400
      local stream = {{content = "Lorem ipsum dolor sit amet lalalalalala", font_size = 20}}
      local lines = wrap(stream, w)

      expect(#lines > 1).to.be(true)
      expect(Fun.iter(lines):all(function(line)
        return Fun.iter(line)
          :map(function(piece) return sprite.get_font(piece.font_size):getWidth(piece.content) end)
          :sum() <= w
      end)).to.be(true)
    end)
  end)

  describe("(stage 4)", function()
    local generate = require("tech.texting._generate")

    it("can generate entities from the list of lines", function()
      local lines = {{{content = "Oh hi Mark", font_size = 20}}}
      local _ = generate(lines, "text")
    end)
  end)
end)
