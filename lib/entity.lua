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
---
--- @field faction? string the name of the faction used to check for hostility

local entityx = {}

--- Check is given position over the entity's hitbox
--- @param position vector
--- @param entity entity
--- @return boolean
entityx.is_over = function(position, entity)
  return position >= entity.position and position < entity.position + entity.size
end

local NO_ENTITY = "<none>"
local NO_NAME = "<no name>"

--- Get best possible in-game naming; prefers .name, then .codename, then the default value
--- @param entity entity?
--- @return string
entityx.name = function(entity)
  if not entity then return NO_ENTITY end
  return entity.name or entity.codename or NO_NAME
end

--- Get best possible in-code naming; prefers .codename, then .name, then the default value
--- @param entity entity?
--- @return string
entityx.codename = function(entity)
  if not entity then return NO_ENTITY end
  return entity.codename or entity.name or NO_NAME
end

return entityx

-- TODO maybe better tech.entity because the module is not exactly an independent library?
--   moreover it kind of describes the main architectural feature of Fallen: in-game entities.
