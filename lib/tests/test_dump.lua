local dump = require("lib.dump")

describe("Serialization library", function()
  describe("basic functionality", function()
    it("dumps a number", function()
      assert.are_equal(1, load(dump(1))())
    end)
    it("dumps a string", function()
      assert.are_equal("abc\n", load(dump("abc\n"))())
    end)
    it("dumps a function", function()
      local f = function()
        return true
      end
      assert.is_true(load(dump(f))()())
    end)
  end)

  describe("complex functionality", function()
    it("dumps a shallow table", function()
      local t = {a = 1, 3}
      assert.are_same(load(dump(t))(), t)
    end)

    it("dumps a shallow table with strange keys", function()
      local t = {["function"] = 1, ["//"] = 2}
      assert.are_same(load(dump(t))(), t)
    end)
  end)
end)
