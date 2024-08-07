local lust = require("lib.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect


local clone = function(x)
  return load(Dump(x))()
end

Log.info("\n\n========== TESTS ==========\n")

describe("Global serialization logic", function()
  it("(experiments)", function()
    local mobs = require("library.mobs")

    -- test function serialization
    local f = function(x)
      Log.info(x)
    end
    loadstring(Dump(f))()("Serialization works!")

    -- test dump size
    local test = function(name, x)
      local dump = Dump(x)
      Log.info("Serialized %s is %.2f KB" % {name, #dump / 1024})
      Log.info("Deserialized: %s" % {pcall(loadstring(dump))})
    end

    test("mob", mobs[1]())
    test("world", State.world)
    test("state", State)

    Log.info(
      "Compressed serialized state is %.2f KB" % (
        #love.data.compress("string", "gzip", Dump(State)) / 1024
      )
    )
  end)

  describe("package data handling", function()
    local package_path = "tests.resources.package"
    it("should not have issues with Theseus's Paradox", function()
      local serialized = Dump(require(package_path))
      package.loaded[package_path] = nil
      local result = load(serialized)()
      local imported = require(package_path)

      expect(result).to.be(imported)

      -- explicit style
      expect(result.fighter).to.be(imported.fighter)
      expect(result.fighter.subclasses.battle_master)
        .to.be(imported.fighter.subclasses.battle_master)

      -- implicit style
      expect(result.rogue).to.be(imported.rogue)
      expect(result.rogue.subclasses.thief)
        .to.be(imported.rogue.subclasses.thief)
    end)

    it("should handle static data recursively", function()
      local rogue = require(package_path).rogue
      local rogue_copy = clone(rogue)
      expect(rogue).to.be(rogue_copy)
    end)
  end)

  describe("metatable serialization", function()
    it("should have a solution", function()
      local example_type = require("tests.resources.example_type")
      local t = example_type(1, 2)
      expect(load(Dump(t))()).to.be(t)
    end)

    it("of Vector", function()
      local v = Vector({1, 2})
      expect(load(Dump(v))()).to.be(v)
      expect(Vector.zero + v).to.be(v)
    end)

    it("of images", function()
      local sprite = require("tech.sprite")

      local original = sprite.image("tests/resources/image.png")
      local copy = load(Dump(original))()
      expect(copy.image:getHeight()).to.be(original.image:getHeight())
      expect({copy.data:getPixel(3, 3)}).to.equal({original.data:getPixel(3, 3)})
    end)

    it("of sound sources", function()
      local sound = require("tech.sound")

      local original = sound("tests/resources/sound.mp3", 0.5)
      local copy = load(Dump(original))()
      expect(copy.source:getDuration()).to.be(original.source:getDuration())
      expect(copy.source:getVolume()).to.be(original.source:getVolume())
    end)

    it("of fonts", function()
      local sprite = require("tech.sprite")

      local original = sprite.text("Hello, world!", 3)
      local copy = load(Dump(original))()
      expect(copy.font:getHeight()).to.be(original.font:getHeight())
    end)
  end)

  describe("known bug fixes", function()
    it("cache collision when 'size' field is encountered", function()
      local t = {size = 1}
      local copy = clone(t)
      expect(copy).to.equal(t)
    end)

    it("sets grid metatable as grid module", function()
      local copy = clone(Grid(Vector({3, 3})))
      expect(getmetatable(copy)).to.be(Grid._grid_mt)
    end)
  end)
end)
