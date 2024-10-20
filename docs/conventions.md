# Conventions

- **Private fields start with `_`, like `._epicenter`.** Isn't enforced everywhere, WIP.
- **Value returned from lua file should be immutable.** If it should be mutable, wrap it in a factory function.
