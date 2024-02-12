from dataclasses import dataclass

from src.lib.vector.vector import int2, ge2, lt2, d2
from src.assets.markup.house import House
from src.assets.markup.zone import Zone
from src.assets.special.level import Markup


@dataclass
class Near:
    area: Zone | House

    def __str__(self):
        return f"у {self.area.name:ро}"


@dataclass
class In:
    area: House

    def __str__(self):
        return f"в {self.area.name:пр}"


@dataclass
class Around:
    def __str__(self):
        return "неподалёку"


def placement(markup: Markup, p: int2) -> Near | In | Around:
    for house in markup.houses:
        if ge2(p, house.house_borders[0]) and lt2(p, house.house_borders[1]):
            return In(house)

    areas = (
        [(zone, zone.center, 2) for zone in markup.zones] +
        [(house, house.house_borders[0], 1) for house in markup.houses] +
        [(house, house.house_borders[1], 1) for house in markup.houses]
    )

    if len(areas) == 0: return Around()

    return Near(min(areas, key=lambda a: d2(a[1], p) / a[2])[0])
