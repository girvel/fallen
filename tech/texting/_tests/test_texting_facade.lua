local lust = require("lib.vendor.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect


describe("Texting facade", function()
  local texting = require("tech.texting")

  it("Can handle a use case", function()
    local root = Html.span {
      Html.h1 {"Header"},
      Html.p {"Hello, world"},
    }

    local entities = texting.generate(root, {default = {font_size = 12}}, 800, "text", {})

    expect(entities[1].sprite.text).to.be("# ")
    expect(entities[2].sprite.text).to.be("Header")
    expect(entities[3].sprite.text).to.be("Hello, world")
  end)
end)
