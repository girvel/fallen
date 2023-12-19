import logging
from dataclasses import dataclass, field
from functools import reduce
from pathlib import Path
from typing import TypeVar, Callable, Type, Iterator, Any, ClassVar, Generator, TYPE_CHECKING

import numpy
import toml as toml
from ecs import Entity, MetasystemFacade

from src.engine.acting.action import Action
from src.engine.language.name import Name
from src.lib.toolkit import to_camel_case, import_module
from src.lib.vector.vector import int2
from src.lib.vector.grid import grid_create, grid_set, grid_get, grid_unsafe_get
from src.library.markup.house import House
from src.library.markup.zone import Zone
from src.library.special.genesis import Genesis

if TYPE_CHECKING:
    from src.engine.rails.rails_base import RailsBase


T = TypeVar('T')


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


@dataclass(eq=False)
class Level(Entity):
    name: Name
    markup: Markup
    config: Config

    grids: dict[str, tuple[list[list[Any]], int2]]
    transparency_cache: numpy.ndarray[Any, numpy.dtype[int]]
    size: int2

    rails: Any
    rails_effect: dict[Any, Action] = field(default_factory=dict)

    no_entity_character: ClassVar[str] = "."
    layers: ClassVar[tuple[str, ...]] = ("tiles", "physical", "effects", "sounds", )
    invisible_layers: ClassVar[tuple[str, ...]] = ("sounds", )

    # TODO NEXT maybe disable rails in a system via flag container entity, not via argument to a Level? less
    #      dependencies that way
    @classmethod
    def create(
        cls, path: Path, genesis: Genesis, disable_rails: bool = False
    ) -> "Level":
        name = Name(f"level {path.stem}")
        logging.info(f"Started loading {name}")

        level_lines = (path / "grid.txt").read_text().split('\n')
        size = (max(len(line) for line in level_lines), len(level_lines))

        result = cls(
            name=name,
            markup=Markup.from_toml_data(**_load_toml(path / "markup.toml")),
            config=Config(**_load_toml(path / "config.toml")),

            grids={layer: grid_create(size, lambda: None) for layer in cls.layers},
            transparency_cache=numpy.full(size, 1),
            size=size,

            rails=None,
        )

        grid_args = {
            tuple(entry["at"]): entry["args"]
            for entry in _load_toml(path / "grid_args.toml").get("entries", [])
        }

        # TODO NEXT REF move all loading to a separate private function
        palette = reduce(lambda a, b: a | b, (
            _load_palette_from(Path("src/library") / layer)
            for layer in cls.layers
            if layer not in cls.invisible_layers
        ))

        for layer in cls.layers:
            if layer in cls.invisible_layers: continue

            local_palette_path = path / "library" / layer
            if local_palette_path.exists():
                palette.update(_load_palette_from(local_palette_path))

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                p = (x, y)

                if c == cls.no_entity_character:
                    continue

                if c not in palette:
                    logging.warning(f"Ignored unknown entity `{c}` at {p}")
                    continue

                genesis.push(palette[c](p=p, level=result, **grid_args.get(p, {})))

        if not disable_rails and (rails_path := path / "rails.py").exists():
            result.rails = genesis.push(import_module(rails_path).Rails(result, genesis))

        genesis.push(result)
        logging.info(f"Finished loading {result.name}")
        return result

    def query(self, request: Callable[[Entity], bool]) -> Iterator[Entity]:
        return (
            e
            for _, layer in self.grids.items()
            for row in layer[0]
            for e in row
            if e and request(e)
        )

    def find(self, entity_type: Type[T]) -> Iterator[T]:
        return self.query(lambda e: isinstance(e, entity_type))

    def put(self, p: int2, entity: T) -> T:
        grid_set(self.grids[entity.layer], p, entity)
        entity.p = p
        entity.level = self
        return entity

    def move(self, p: int2, entity: T) -> T:
        grid_set(self.grids[entity.layer], entity.p, None)
        self.put(p, entity)

    @staticmethod
    def change(entity: T, target: "Level", p: int2) -> T:
        grid_set(entity.level.grids[entity.layer], entity.p, None)
        entity.level = target
        target.put(p, entity)


def _load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        cls = getattr(import_module(p), to_camel_case(p.stem))
        result[cls.character] = cls

    return result


def _load_toml(path: Path):
    return toml.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
