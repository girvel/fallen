from dataclasses import dataclass
from statistics import mean

from src.lib.vector import int2, ge2, lt2, d2, average2
from src.library.markup.house import House
from src.library.markup.zone import Zone
from src.library.special.level import Markup


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


def placement(markup: Markup, p: int2) -> Near | In:
    for house in markup.houses:
        if ge2(p, house.house_borders[0]) and lt2(p, house.house_borders[1]):
            return In(house)

    areas = (
        [(zone, zone.center) for zone in markup.zones] +
        [(house, house.house_borders[0]) for house in markup.houses] +
        [(house, house.house_borders[1]) for house in markup.houses]
    )

    return Near(min(areas, key=lambda a: d2(a[1], p))[0])