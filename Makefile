run:
	py.exe -3.10 fallen.py $(FLAGS)

debug:
	py.exe -3.10 fallen.py -d $(FLAGS)

profile:
	py.exe -3.10 -m cProfile -o .profile fallen.py -d -t stuff/tracks/random.txt --no-rails $(FLAGS)
	echo "sort cumtime\nstats" | py.exe -3.10 -m pstats .profile | less

line_profile:
	kernprof.exe -lv fallen.py $(FLAGS)

stats:
	cat `find . -type f -name "*.py" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.csv"` | wc -l
