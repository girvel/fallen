#!/bin/env zsh
a=$(cat **/*.lua | wc -l)
cd lib; b=$(cat lust.lua profile.lua argparse.lua inspect.lua fun.lua memoize.lua strong.lua tiny.lua log.lua htmlparser/*.lua | wc -l)
echo $((a - b))
