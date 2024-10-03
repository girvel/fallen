# Texting module

Provides functionality for turning raw text into displayable in-game entities. `tech.texting` is an idiomatic way to display text; in comparison to direct `love.graphics.printf` call, it handles fully functional entities that can be interacted with, animated, moved etc.

## Overview

Putting "Hello, world!" on screen:

```lua
State:add_multiple(texting.generate(
    "Hello, world!", {default = {font_size = 18}}, 1000, "wiki"
))
```

## In-depth

All text in Fallen is HTML-based and stored in a tree-like format. It can be parsed from a raw HTML string or generated directly using [lib.html](/lib/_docs/html.md). These two pieces of code are equivalent:

```lua
-- parsing from raw HTML
local page = texting.parse('<div>Hello, <span color="ff0000">world</span>!</div>')

-- generating directly
local page = Html.div {
    "Hello, ",
    Html.span {color = {1, 0, 0}, "world"},
    "!",
}
```

Notice that `texting.parse` converts attributes "color", "if", "on_update", "on_hover", "on_click" to other types.

To display text, you need to generate entities and add them to the state:

```lua
State:add_multiple(texting.generate(page, {default = {font_size = 18}}, 1000, "wiki", {}))
```

`texting.generate` accepts:

1. the tree representing the page itself
2. styles in format {<tag name or "default"> = {...}}
3. maximal text width for wrapping
4. view (layer) for entities
5. arguments for `<script>`s and `if` attributes

All the attributes and styles are passed as-is into the entities except for "content", "color" and "on_update": content and color become parts of the sprite, and on_update becomes ai.observe(). Also "if" attribute is special: it contains lua expression evaluated when generating the page, allowing to hide the tag conditionally.

Some tags are special and behave differently. Read the `_processors.lua` and `transformers.lua` to know more; this documentation piece is long enough.
