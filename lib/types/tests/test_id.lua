describe("Id", function()
  local id = require("lib.types.id")

  it("is unique", function()
    assert.not_equal(id "123", id "123")
  end)

  it("converts to string", function()
    assert.equal("abc", tostring(id "abc"))
  end)
end)
