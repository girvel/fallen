# Code style conventions

## Maximal string length

120

## Naming

Basically naming convention is:

0. Longer, but more understandable names are preffered over shorter, but less understandable. **Exception:** project vocabulary.
1. Collections end with -s like `items` if they consist of items, and do not end with -s like `physical` if they are collections of physical things
2. Iteration variables can be single-letter like `for p in patterns`
3. Vector functions end with -2, like `add2` for vector addition

## Project vocabulary

### General terms

| Term | Meaning  |
|---|---|
| p | position |
| v | direction of movement |
| ms | metasystem (from ecs.Metasystem) |

### Terms borrowed from math

| Term | Meaning  |
|---|---|
| x, y | coordinates |
| dx, dy | dx = x1 - x0, dy = y1 - y0 |
| rx, ry | coordinates relative to current base |
| d | diameter |
| r | radius |