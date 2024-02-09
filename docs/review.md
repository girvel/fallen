# Review notes from 2024.02.02 on overall state of Fallen

- AI -- discard Composite, that was a shitty abstraction
- Level, prep time & player placement should not be done by hand; maybe use rails?
- Rails should be disabled via global configuration entity, not via Level.create's argument
- HTML rendering is too hacky: two separate top and bottom grids

## Documentation
- Documentation is kind of old
- There is no description of processes, s. a. game cycle, entity creation/destruction etc.