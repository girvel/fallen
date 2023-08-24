from collections import namedtuple


class Attack(namedtuple("AttackBase", "v")):
    def execute(self, movable, level, hades):
        next_p = movable.p + self.v
        if next_p.get_in(level.level_grid) is not None:
            enemy = next_p.get_in(level.level_grid)

            if "health" in enemy:
                enemy.health -= movable.power
                if enemy.health <= 0:
                    hades.entities_to_destroy.append(enemy)