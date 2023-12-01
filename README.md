English [Русский](/README.ru.md)

# Fallen: reactive mini-RPG

I always wanted to create my own RPG, here it is.

![(Here should have been a screenshot, I don't know what went wrong)](assets/screenshot.png)

## Installation

(Command samples are for Windows, if you use Linux you definetely can figure out how to run a python script)

1. Install [Python 3.10](https://www.python.org/downloads/release/python-31011/) (does not work on any other python version)
2. Download the [latest release](https://github.com/girvel/fallen/releases/latest) - file `Source code (zip)` will do
3. Unpack the archive
4. Open the terminal and go to game folder:

Switch to disk, on which you downloaded your archive (for me it is disk D)

```commandline
D:
```

Go to the unpacked game folder -- there should be a `fallen.py` file in it (for me it is D:\Downloads\fallen-0.1.0):

```commandline
cd D:\Downloads\fallen-0.1.0
```

5. Install dependencies:

```commandline
py.exe -3.10 -m pip install -r requirements.txt
```

6. Run the game:

```commandline
py.exe -3.10 fallen.py
```

To run the game again just repeat steps 4 and 6.

# Development section

## Development installation

1. Install [Git](https://git-scm.com/) and [Python 3.10](https://www.python.org/downloads/release/python-31011/) (does not work on any other python version)
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

## Documentation

See `docs/`

## Makefile

Basically a container for most use cases. `make` to run the game, `make debug` to run the game with debug utilities, `make profile` to run profiler, `make line_profile` to run line profiler.

# Credits

- Creator: [Nikita Dobrynin / girvel](https://github.com/girvel)
- Testing/game design: [Alexlosos](https://github.com/potekhinavas)
