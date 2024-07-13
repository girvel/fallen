local argparse = require("lib.argparse")

return {
  parse = function(args)
    args[-2] = nil
    args[-1] = nil

    local parser = argparse()
      :name("Unalive")
      :description("Launch the Unalive")

    parser:option(
      "-c --checkpoints",
      "Scenes to enable before the start of the game"
    )
      :args("?")
      :default({})

    parser:option(
      "-l --level",
      "Name of the level to load."
    )
      :args(1)
      :default("demo")

    parser:flag(
      "-d --debug",
      "Enable debug mode"
    )

    parser:flag(
      "-A --disable-ambient",
      "Disable background sound"
    )

    return parser:parse(args)
  end,
}
