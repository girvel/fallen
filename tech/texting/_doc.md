# Texting module

Provides functionality for turning raw text into displayable in-game entities. `tech.texting` is an idiomatic way to display text; in comparison to direct `love.graphics.printf` call, it handles fully functional entities that can be interacted with, animated, moved etc.

## Overview

Putting "Hello, world!" on screen:

```lua
-- TODO! test if this works
State:add(texting.generate(
    "Hello, world!", {default = {font_size = 18}}, 1000, "wiki"
))
```

## In-depth

<stages of texting, managing created entities, word wrapping, HTML storage and generation, attribute handling, attribute types, tags>

## API

TODO! finish writing docs for texting
TODO! docs for HTML module
TODO! connect both docs
