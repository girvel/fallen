from ecs import OwnedEntity
from src.lib.vector import Vector, zero


# class Level(OwnedEntity):
#     def __init__(self):
#         super().__init__(name='level_container', size=Vector(100, 100))
#         self.level_grid = self.size.create_grid(None)
#
#     def put(self, movable, p):
#         p.set_in(self.level_grid, movable)
#         movable.p = p
#         movable.v = zero
#         return movable
#
level = OwnedEntity(name='level_container', size=Vector(100, 100))
level.level_grid = level.size.create_grid(None)

def put(movable, p):
    p.set_in(level.level_grid, movable)
    movable.p = p
    movable.v = zero
    return movable

level.put = put