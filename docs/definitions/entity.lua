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
---
--- @field sprite sprite
--- @field shader? shader shader used specifically for this entity; surpasses State's shader
local entity = {}

-- TODO should be joined w/ lib.entity as tech.entity?
