#!/bin/env zsh
a=$(cat **/*.lua | wc -l)
b=$(cat lib/vendor/**/*.lua | wc -l)
echo $((a - b))
