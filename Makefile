run:
	py.exe -3.10 fallen.py

profile:
	py.exe -3.10 -m cProfile -o .profile fallen.py -t assets/benchmark_tracks/vision.txt
	echo "sort cumtime\nstats" | py.exe -3.10 -m pstats .profile | less

line_profile:
	kernprof.exe -lv fallen.py
