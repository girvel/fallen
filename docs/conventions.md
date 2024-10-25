# Conventions

- **Casing:**
  - `CamelCase` for globals
  - `SCREAMING_SNAKE_CASE` for constants (any constants)
  - `snake_case` otherwise: locals, fields
- **2-space indent, 100 line width.** Line width isn't enforced in rails.
- **Private fields start with `_`, like `._epicenter`.** Isn't enforced everywhere, WIP.
- **Value returned from lua file should be immutable.** If it should be mutable, wrap it in a factory function.
