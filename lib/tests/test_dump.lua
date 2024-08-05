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
end)
