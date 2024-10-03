# Html manipulation library

```lua
Html = require("lib.html")
```

Library for generation, storage and parsing HTML.

## Generation

```lua
local page = Html.pre {
  color = {1, 1, 0},
  on_click = function() error() end,
  "Hello, ",
  Html.a {
    href = "/world.md",
    "world"
  }
}
```

Generates a tree with .attributes, .content and .name node fields. Allows visual information to be stored in an intermediate easy-to-work-with format between raw .html text file and ready-to-render collection of entities.

## Parsing HTML

```lua
local page = Html().parse(
    '<pre color="ffff00">Hello, world!</pre>',
    {color = Colors.from_hex}
)
```

Generates a tree from raw HTML, converts attributes with given functions.

## Building tables

`Html().build_table` is a convenience function for building HTML table with tds and trs from the given 2d matrix.

```lua
local html_table = Html().build_table {
    {"1", "2"},
    {Html.span {"1", tostring(2 + 2)}, "28"}
}
```
