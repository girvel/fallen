#!/bin/env zsh
mkdir -p .build
rm -rf .build/*

zip -9 -r .build/fallen.love assets kernel lib library mech state systems tech conf.lua main.lua

cat "$(which love.exe)" .build/fallen.love > .build/fallen.exe
rm .build/fallen.love

mkdir -p .build/fallen
mv .build/fallen.exe .build/fallen/fallen.exe
cp "$(dirname "$(which love.exe)")"/*.dll .build/fallen/
cp lib/**/*.dll .build/fallen/
cd .build; zip -9 -r fallen_win64.zip fallen; cd ..

rm -rf .build/fallen
