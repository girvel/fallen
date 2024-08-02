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
      "-s --scenes",
      "Scenes to run immediately after the start of the game"
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

    parser:option(
      "-r --resolution",
      "Run in windowed mode with fixed resolution; format is <width>x<height> or 1080p, 720p, 360p"
    )

    parser:flag(
      "-p --enable-profiler",
      "Enable profiler; result will be displayed in logs"
    )

    local result = parser:parse(args)

    if result.resolution then
      local builtin_resolutions = {
        ["1080p"] = Vector({1920, 1080}),
        ["720p"] = Vector({1280, 720}),
        ["360p"] = Vector({640, 360}),
      }

      result.resolution = builtin_resolutions[result.resolution]
        or Vector(Fun.iter(result.resolution / "x"):map(tonumber):totable())
    end

    return result
  end,
}
