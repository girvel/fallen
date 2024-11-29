#!/bin/env zsh
excessive_total=$(cat **/*.lua | wc -l)
vendor=$(cat vendor/**/*.lua | wc -l)
total=$((excessive_total - vendor))
scripts=$(cat assets/**/*.lua | wc -l)
not_scripts=$((total - scripts))

echo "Script code:      $scripts"
echo "Non-script code:  $not_scripts"
echo "Total:            $total"
