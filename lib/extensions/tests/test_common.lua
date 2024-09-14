describe("Common module", function()
  _G.unpack = table.unpack
  _G.package.loaded.ffi = {}
  local common = require("lib.extensions.common")

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

  describe("number_type", function()
    it("differentiates integers and floats", function()
      assert.is_true(nil == common.number_type({}))
      assert.equal("integer", common.number_type(1))
      assert.equal("float", common.number_type(1.1))
    end)
  end)
end)
