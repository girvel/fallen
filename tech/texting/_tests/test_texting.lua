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
    local tokenizer = require("tech.texting._tokenizer")

    it("can turn html-based tree into the list of tokens", function()
      local node = Html.div {
        "Hello, ",
        Html.span {
          "world",
        }
      }

      local tokens = tokenizer.visit(node, {}, {default = {}})

      expect(tokens).to.equal({{content = "Hello, "}, {content = "world"}})
    end)
  end)
end)
