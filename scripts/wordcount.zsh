#!/bin/env zsh
a=$(cat **/*.lua | wc -l)
b=$(cat vendor/**/*.lua | wc -l)
echo $((a - b))
