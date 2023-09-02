# Fallen: detail-oriented mini-RPG game

I always wanted to create my own RPG, here it is.

![(Here should have been a screenshot, I don't know what went wrong)](assets/screenshot.png)

## Installation

1. Install [Git](https://git-scm.com/) and [Python](https://www.python.org/downloads/) (3.10+)
2. Open the terminal and go to preffered installation directory
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