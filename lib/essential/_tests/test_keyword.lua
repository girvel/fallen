describe("lib.essential.keyword", function()
  local keyword = require("lib.essential.keyword")

  it("Allows .. syntax for functions", function()
    local f = keyword .. function(_, x) return x + 1 end
    assert.equal(3, f(2))
    assert.equal(3, f .. 2)
  end)
end)
