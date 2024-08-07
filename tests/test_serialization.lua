local lust = require("lib.lust")
local describe = lust.describe
local it = lust.it
local expect = lust.expect


local clone = function(x)
  return load(Dump(x))()
end

describe("Global serialization logic", function()
  describe("package data handling", function()
    it("should not have issues with Theseus's Paradox", function()
      local package_path = "tests.resources.package"
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

  describe("known bugs", function()
    it("cache collision when 'size' field is encountered", function()
      local t = {size = 1}
      local copy = clone(t)
      expect(copy).to.equal(t)
    end)
  end)
end)
