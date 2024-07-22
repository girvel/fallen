local common = require("lib.common")


describe("Common module", function()
  describe("get_path", function()
    it("gets the table contents recursively", function()
      assert.equal(
        3, common.get_by_path({a = {b = {c = 3}}}, {"a", "b", "c"})
      )
    end)
  end)

  describe("set_path", function()
    it("sets the table contents recursively", function()
      local t = {}
      common.set_by_path(t, {"a", "b", "c"}, 3)
      assert.same({a = {b = {c = 3}}}, t)
    end)
  end)
end)
