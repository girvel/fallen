from ecs import OwnedEntity
from src.lib.vector import Vector, zero


level = OwnedEntity(name='level_container', size=Vector(100, 100))
level.level_grid = level.size.create_grid(None)

def put(movable, p):
    p.set_in(level.level_grid, movable)
    movable.p = p
    movable.v = zero
    return movable

level.put = put