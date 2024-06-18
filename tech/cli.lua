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

    parser:flag(
      "-d --debug",
      "Enable debug mode"
    )

    return parser:parse(args)
  end,
}
