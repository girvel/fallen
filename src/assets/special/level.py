import logging
from dataclasses import dataclass, field
from functools import reduce
from pathlib import Path
from typing import TypeVar, Callable, Type, Iterator, Any, ClassVar

import numpy
import toml
from ecs import Entity, exists

from src.engine.acting.action import Action
from src.engine.language.name import Name
from src.lib.time import Time
from src.lib.toolkit import to_camel_case, import_module
from src.lib.vector.grid import grid_create, grid_set
from src.lib.vector.vector import int2
from src.assets.markup.house import House
from src.assets.markup.zone import Zone
from src.components import Genesis, Positioned, Hades

TPositioned = TypeVar('TPositioned', bound=Positioned)


@dataclass
class Markup:
    zones: list[Zone]
    houses: list[House]

    @classmethod
    def from_toml_data(cls, houses: list[dict] = None, zones: list[dict] = None):
        return cls(
            houses=[House.from_markup(**h) for h in houses or []],
            zones=[Zone.from_markup(**h) for h in zones or []],
        )


@dataclass
class Config:
    prep_ticks: int = 0
    start_time: list[int] = field(default_factory=lambda: [6, 0, 0])


@dataclass(eq=False)
class Level(Entity):
    name: Name
    markup: Markup
    config: Config

    time: Time

    grids: dict[str, tuple[list[list[TPositioned]], int2]]
    transparency_cache: numpy.ndarray[Any, numpy.dtype[int]]
    size: int2

    rails: Any
    rails_effect: dict[Any, Action] = field(default_factory=dict)

    no_entity_character: ClassVar[str] = "."
    layers: ClassVar[tuple[str, ...]] = ("tiles", "physical", "effects", "sounds", )
    invisible_layers: ClassVar[tuple[str, ...]] = ("sounds", )

    # TODO maybe disable rails in a system via flag container entity, not via argument to a Level? less
    #      dependencies that way
    @classmethod
    def create(
        cls, path: Path, hades: Hades, genesis: Genesis, disable_rails: bool = False
    ) -> "Level":
        name = Name(f"level {path.stem}")
        logging.info(f"Started loading {name}")

        level_lines = (path / "grid.txt").read_text().split('\n')
        size = (max(len(line) for line in level_lines), len(level_lines))
        config = Config(**_load_toml(path / "config.toml"))

        result = cls(
            name=name,
            markup=Markup.from_toml_data(**_load_toml(path / "markup.toml")),
            config=config,

            time=Time(*config.start_time),

            grids={layer: grid_create(size, lambda: None) for layer in cls.layers},
            transparency_cache=numpy.full(size, 1),
            size=size,

            rails=None,
        )

        for loaded_entity in result._load_grid(path, level_lines):
            genesis.push(loaded_entity)

        if not disable_rails and (rails_path := path / "rails.py").exists():
            result.rails = genesis.push(import_module(rails_path).Rails(result, hades, genesis))

        genesis.push(result)
        logging.info(f"Finished loading {result.name}")
        return result

    def destroy(self, hades: Hades):
        logging.info(f"Destroying {self.name}")

        for grid in self.grids.values():
            for row in grid[0]:
                for destroyed_entity in row:
                    if destroyed_entity is not None and exists(destroyed_entity):
                        hades.push(destroyed_entity)

        if self.rails is not None: hades.push(self.rails)
        hades.push(self)

    def _load_grid(self, base_path: Path, level_lines: list[str]) -> Iterator[Any]:
        grid_args = {
            tuple(entry["at"]): entry["args"]
            for entry in _load_toml(base_path / "grid_args.toml").get("entries", [])
        }

        palette = reduce(lambda a, b: a | b, (
            _load_palette_from(Path("src/assets") / layer)
            for layer in self.layers
            if layer not in self.invisible_layers
        ))

        for layer in self.layers:
            if layer in self.invisible_layers: continue

            local_palette_path = base_path / "assets" / layer
            if local_palette_path.exists():
                palette.update(_load_palette_from(local_palette_path))

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                p = (x, y)

                if c == self.no_entity_character:
                    continue

                if c not in palette:
                    logging.warning(f"Ignored unknown entity `{c}` at {p}")
                    continue

                yield palette[c](p=p, level=self, **grid_args.get(p, {}))

    def query(self, request: Callable[[Entity], bool]) -> Iterator[Entity]:
        return (
            e
            for _, layer in self.grids.items()
            for row in layer[0]
            for e in row
            if e and request(e)
        )

    def find(self, entity_type: Type[TPositioned]) -> Iterator[TPositioned]:
        return self.query(lambda e: isinstance(e, entity_type))

    @classmethod
    def put(cls, entity: TPositioned):
        grid_set(entity.level.grids[entity.layer], entity.p, entity)

        if entity.layer == "physical":
            entity.level.transparency_cache[entity.p] = int(not hasattr(entity, "solid_flag"))

    @classmethod
    def remove(cls, entity: TPositioned):
        grid_set(entity.level.grids[entity.layer], entity.p, None)

        if entity.layer == "physical":
            entity.level.transparency_cache[entity.p] = 1

    @classmethod
    def move(cls, entity: TPositioned, p: int2, *, level: "Level | None" = None):
        cls.remove(entity)
        entity.p = p
        if level is not None: entity.level = level
        cls.put(entity)


def _load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        cls = getattr(import_module(p), to_camel_case(p.stem))
        result[cls.character] = cls

    return result


def _load_toml(path: Path):
    return toml.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
