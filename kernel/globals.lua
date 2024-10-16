return function()
  Log = require("lib.vendor.log")
  Fun = require("lib.vendor.fun")
  Tiny = require("lib.vendor.tiny")
  Inspect = require("lib.vendor.inspect")
  Memoize = require("lib.vendor.memoize")
  Json = require("lib.vendor.json")

  Log.info("Starting basic LOVE setup")

  _G.Table = require("lib.essential.table")
  require("lib.essential.string").inject(getmetatable(""))
  _G.Query = require("lib.essential.query")
  _G.Math = require("lib.essential.math")
  _G.Common = require("lib.essential.common")
  _G.Debug = require("lib.essential.debug")
  _G.Random = require("lib.essential.random")
  _G.Entity = require("lib.essential.entity")
  _G.Fn = require("lib.essential.fn")
  _G.Keyword = require("lib.essential.keyword")
  _G.Type = require("lib.essential.type")
  _G.Module = require("lib.essential.module")

  Enum = require("lib.types.enum")
  Vector = require("lib.types.vector")
  Grid = require("lib.types.grid")
  D = require("lib.types.d")
  Colors = require("lib.colors")
  OrderedMap = require("lib.types.ordered_map")
  Promise = require("lib.types.promise")

  Html = require("lib.html")
  Dump = require("lib.dump")
  Dump.require_path = "lib.dump"
  Tcod = require("lib.tcod")

  require("lib.tiny_dump_patch")()
end
