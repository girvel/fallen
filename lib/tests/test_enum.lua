local enum = require("lib.enum")

describe("Enum module", function()
  it("works for the use case", function()
    local tested_enum = enum({
      first = {},
      second = {"argument"},
    })

    assert.equal(1, tested_enum.second(1).argument)
    assert.same({true}, {tested_enum.first.unpack(tested_enum.first())})
    assert.same({true, 2}, {tested_enum.second.unpack(tested_enum.second(2))})
    assert.same({false}, {tested_enum.first.unpack(tested_enum.second(3))})

    assert.equal(tested_enum.second, tested_enum.second(3).enum_variant)
    assert.same({3}, {tested_enum.second(3):unpack()})
  end)
end)
