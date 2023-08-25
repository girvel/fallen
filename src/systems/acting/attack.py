from collections import namedtuple


class Attack(namedtuple("AttackBase", "v")):
    def execute(self, actor, level, hades):
        next_p = actor.p + self.v
        if next_p.get_in(level.level_grid) is None: return

        enemy = next_p.get_in(level.level_grid)

        if "health" in enemy:
            enemy.health -= actor.power
            enemy.receives_damage = True
            if enemy.health <= 0:
                hades.entities_to_destroy.append(enemy)

        actor.act = None
