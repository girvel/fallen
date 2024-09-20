# Texting module

Provides functionality for turning raw text into displayable in-game entities. `tech.texting` is an idiomatic way to display text, because it is much more robust in comparison to direct `love.graphics.printf` call.

## Overview

Putting "Hello, world!" on screen:

```lua
-- TODO! test if this works
State:add(texting.generate(
    "Hello, world!", {default = {font_size = 18}}, 1000, "wiki"
))
```

## In-depth

<managing entities, wrapping, attribute handling, attribute types>

## API

TODO! finish writing docs for texting
TODO! docs for HTML module
TODO! connect both docs
