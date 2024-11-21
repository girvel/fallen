--- @class entity
--- Abstract class for all in-game ECS entities.
--- Contains all possible public fields.
---
--- @field name? string name to be displayed in-game
--- @field codename? string name to be displayed/used as an index in-code
---
--- @field position? vector in-game position in relation to `.view`
--- @field size? vector size (in `.view`)
--- @field view? string coordinate system's index in `State.gui.views`
--- @field layer? layer layer in `State.grids`
---
--- @field sprite? sprite
--- @field shader? shader shader used specifically for this entity; surpasses State's shader
---
--- @field hp? integer current amount of health points; hp <= 0 means death
--- @field get_max_hp? fun(self: entity): integer calculate maximal possible amount of HP
---
--- @field inventory? {[string]: table} single-item displayable inventory slots
---
--- @field ai? ai
---
--- @field boring_flag? true disable logging `State:remove`
--- @field creature_flag? true entity was created as mech.creature
---
--- @field last_initiative? number value of the last initiative roll

local entityx = {}

entityx.is_over = function(position, entity)
  return position >= entity.position and position < entity.position + entity.size
end

entityx.name = function(entity)
  return -Query(entity).name or -Query(entity).codename or "???"
end

return entityx

-- TODO maybe better tech.entity because the module is not exactly an independent library?
--   moreover it kind of describes the main architectural feature of Fallen: in-game entities.
