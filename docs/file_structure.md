# Project's file structure

## Root folder overview

```
.git/  -- git files, google "git"
.github/  -- github actions automation
assets/  -- non-code assets s. a. images, animations, html pages, ...
docs/  -- global documentation
kernel/  -- core initialization; contains LOVE callbacks, custom events, globals, ...
lib/  -- (relatively) portable libaries, non-specific to Fallen itself
  vendor/  -- 3rd party libraries
library/  -- code assets s. a. entity factories, AIs, factions, ...
mech/  -- game mechanics code
scripts/  -- development scripts
state/  -- game state code; files often match global `State`'s fields: for example, code for
        -- `State.gui.creator` is stored in `/state/gui/creator/init.lua`
systems/  -- ECS systems, google "ECS"
tech/  -- non-game mechanics code s. a. 
tests/  -- integration tests
.busted  -- busted configuration file, google "busted"
.gitignore  -- google "git"
.luarc.json  -- Lua LSP configuration file for the project
conf.lua  -- LOVE configuration
main.lua  -- LOVE launch script
README.md  -- README file, kind of self-explanatory
```

## Code folders

- `init.lua` files are lua standard for requiring the folder itself
- `_doc.md` contains documentation for the module
- `_tests/` contains unit tests
- files starting with `_` are considered internal for the module; they are not intended for requiring from the outside
