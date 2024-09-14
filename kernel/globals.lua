return function()
  Log = require("lib.vendor.log")
  Fun = require("lib.vendor.fun")
  Tiny = require("lib.vendor.tiny")
  Inspect = require("lib.vendor.inspect")
  Memoize = require("lib.vendor.memoize")
  Json = require("lib.vendor.json")

  Log.info("Starting basic LOVE setup")

  Pairs = require("lib.extensions.pairs")
  Table = require("lib.extensions.table")
  require("lib.extensions.string").inject(getmetatable(""))
  Query = require("lib.types.query")
  Math = require("lib.extensions.math")
  Common = require("lib.extensions.common")
  Debug = require("lib.extensions.debug")
  Random = require("lib.extensions.random")
  Entity = require("lib.extensions.entity")
  Fn = require("lib.extensions.fn")

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

  require("lib.tiny_dump_patch")()
end
