return function()
  Log = require("vendor.log")
  Fun = require("vendor.fun")
  Tiny = require("vendor.tiny")
  Inspect = require("vendor.inspect")
  Memoize = require("vendor.memoize")
  Json = require("vendor.json")

  Log.info("Starting basic LOVE setup")

  _G.Table = require("lib.table")
  require("lib.string").inject(getmetatable(""))
  _G.Query = require("lib.query")
  _G.Math = require("lib.math")
  _G.Common = require("lib.common")
  _G.Debug = require("lib.debug")
  _G.Random = require("lib.random")
  _G.Entity = require("lib.entity")
  _G.Fn = require("lib.fn")
  _G.Keyword = require("lib.keyword")
  _G.Type = require("lib.type")
  _G.Module = require("lib.module")

  Enum = require("lib.enum")
  Vector = require("lib.vector")
  Grid = require("lib.grid")
  D = require("lib.d")
  Colors = require("lib.colors")
  OrderedMap = require("lib.ordered_map")
  Promise = require("lib.promise")

  Html = require("lib.html")
  Dump = require("lib.dump")
  Dump.require_path = "lib.dump"

  require("lib.tiny_dump_patch")()
end
