local serpent = require("lib.serpent")


describe("Global serialization process", function()
  describe("package data handling", function()
    it("should not have issues with Theseus's Paradox", function()
      local package_path = "tests.resources.package"
      local p = require(package_path)
      local serialized = serpent.dump(p, {metatostring = false})
      package.loaded[package_path] = nil

      assert.equal(require(package_path), load(serialized)())
    end)
  end)
end)
