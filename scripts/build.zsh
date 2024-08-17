#!/bin/env zsh
mkdir -p .build

zip -9 -r .build/fallen.love assets lib library mech state systems tech utils conf.lua main.lua

rm -f .build/fallen.exe
cat "$(which love.exe)" .build/fallen.love > .build/fallen.exe
rm .build/fallen.love

rm -rf .build/fallen
mkdir -p .build/fallen
mv .build/fallen.exe .build/fallen/fallen.exe
cp "$(dirname "$(which love.exe)")"/*.dll .build/fallen/
cp lib/*.dll .build/fallen/
cd .build; zip -9 -r fallen.zip fallen; cd ..

rm -rf .build/fallen
