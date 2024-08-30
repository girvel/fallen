# Conventions

- **Private fields start with `_`, like `._epicenter`.** Any public field of an entity is a component, that can be read or changed from the outside, all private fields are just fields. This standard allows to tell that `entity.codename` is a component and `entity._epicenter` is a private field.
