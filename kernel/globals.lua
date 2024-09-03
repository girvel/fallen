return function()
  Log = require("lib.log")
  Fun = require("lib.fun")
  Tiny = require("lib.tiny")
  Inspect = require("lib.inspect")
  Memoize = require("lib.memoize")
  Json = require("lib.json")
  Html = require("lib.html")

  Log.info("Starting basic LOVE setup")

  Pairs = require("lib.extensions.pairs")
  Table = require("lib.extensions.table")
  require("lib.extensions.string").inject(getmetatable(""))

  Query = require("lib.types.query")
  Math = require("lib.extensions.math")
  Common = require("lib.common")
  Debug = require("lib.extensions.debug")
  Random = require("lib.extensions.random")

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
