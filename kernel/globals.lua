return function()
  Log = require("vendor.log")
  Fun = require("vendor.fun")
  Tiny = require("vendor.tiny")
  Inspect = require("vendor.inspect")
  Memoize = require("vendor.memoize")
  Json = require("vendor.json")

  Log.info("Starting basic LOVE setup")

  Table = require("lib.table")
  require("lib.string").inject(getmetatable(""))
  Query = require("lib.query")
  Math = require("lib.math")
  Common = require("lib.common")
  Debug = require("lib.debug")
  Random = require("lib.random")
  Entity = require("lib.entity")
  Fn = require("lib.fn")
  Keyword = require("lib.keyword")
  Type = require("lib.type")
  Module = require("lib.module")

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
