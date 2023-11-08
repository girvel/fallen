English [Русский](/README.ru.md)

# Fallen: reactive mini-RPG

I always wanted to create my own RPG, here it is.

![(Here should have been a screenshot, I don't know what went wrong)](assets/screenshot.png)

## Installation

1. Install [Git](https://git-scm.com/) and [Python 3.10](https://www.python.org/downloads/)
2. Open the terminal and go to your preffered installation directory
3. Clone the repository

```bash
git clone https://github.com/girvel/fallen
cd fallen
```

4. Install dependencies:

```shell
pip install -r requirements.txt
```

5. Launch the game:

```shell
python fallen.py
```

# Development section

## Documentation

See `docs/`

## Makefile

Basically a container for most use cases. `make` to run the game, `make debug` to run the game with debug utilities, `make profile` to run profiler, `make line_profile` to run line profiler.

# Credits

- Creator: [Nikita Dobrynin / girvel](https://github.com/girvel)
- Testing/game design: [Alexlosos](https://github.com/potekhinavas)
