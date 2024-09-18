return function()
  Log = require("lib.vendor.log")
  Fun = require("lib.vendor.fun")
  Tiny = require("lib.vendor.tiny")
  Inspect = require("lib.vendor.inspect")
  Memoize = require("lib.vendor.memoize")
  Json = require("lib.vendor.json")

  Log.info("Starting basic LOVE setup")

  Pairs = require("lib.essential.pairs")
  Table = require("lib.essential.table")
  require("lib.essential.string").inject(getmetatable(""))
  Query = require("lib.types.query")
  Math = require("lib.essential.math")
  Common = require("lib.essential.common")
  Debug = require("lib.essential.debug")
  Random = require("lib.essential.random")
  Entity = require("lib.essential.entity")
  Fn = require("lib.essential.fn")

  Html = require("lib.html")
  Dump = require("lib.dump")
  Dump.require_path = "lib.dump"
  Module = require("lib.types.module")

  Enum = require("lib.types.enum")
  Vector = require("lib.types.vector")
  Grid = require("lib.types.grid")
  D = require("lib.types.d")
  Colors = require("lib.colors")
  OrderedMap = require("lib.types.ordered_map")
  Promise = require("lib.types.promise")
  Keyword = require("lib.types.keyword")
  Type = require("lib.types.type")

  require("lib.tiny_dump_patch")()
end
