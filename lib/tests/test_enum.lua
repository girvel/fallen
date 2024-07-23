local enum = require("lib.enum")

describe("Enum module", function()
  it("works for the use case", function()
    local tested_enum = enum("tested_enum", {
      first = {},
      second = {"argument"},
    })

    assert.equal(1, tested_enum.second(1).argument)
    assert.same({true}, {tested_enum.first.unpack(tested_enum.first())})
    assert.same({true, 2}, {tested_enum.second.unpack(tested_enum.second(2))})
    assert.same({false}, {tested_enum.first.unpack(tested_enum.second(3))})
  end)
end)
