run:
	py.exe -3.10 fallen.py $(FLAGS)

debug:
	py.exe -3.10 fallen.py -d $(FLAGS)

profile:
	py.exe -3.10 -m cProfile -o .profile fallen.py -d -t assets/benchmark_tracks/vision.txt --no-rails $(FLAGS)
	echo "sort cumtime\nstats" | py.exe -3.10 -m pstats .profile | less

line_profile:
	kernprof.exe -lv fallen.py $(FLAGS)

stats:
	cat `find . -name "*.py"` | wc -l
