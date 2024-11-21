local enum = require("lib.types.enum")

describe("Enum module", function()
  _G.unpack = table.unpack
  _G.Fun = require("vendor.fun")

  local tested_enum = enum({
    first = {},
    second = {"argument"},
  })

  it("works for the use case", function()
    assert.equal(1, tested_enum.second(1).argument)
    assert.same({true}, {tested_enum.first.unpack(tested_enum.first())})
    assert.same({true, 2}, {tested_enum.second.unpack(tested_enum.second(2))})
    assert.same({false}, {tested_enum.first.unpack(tested_enum.second(3))})

    assert.equal(tested_enum.second, tested_enum.second(3).enum_variant)
    assert.same({3}, {tested_enum.second(3):unpack()})
  end)

  it("has __eq for variants", function()
    assert.equal(tested_enum.second(3), tested_enum.second(3))
    assert.not_equal(tested_enum.second(nil), tested_enum.second(3))
  end)
end)
