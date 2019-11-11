all: parse-filebench parse-cpu-stats parse-disk-stats 

parse-filebench:
	g++ -std=c++11 parse-filebench.cpp -o parse-filebench

parse-cpu-stats:
	g++ -std=c++11 parse-cpu-stats.cpp -o parse-cpu-stats

parse-disk-stats:
	g++ -std=c++11 parse-disk-stats.cpp -o parse-disk-stats

clean:
	rm -rf parse-filebench
	rm -rf parse-cpu-stats
	rm -rf parse-disk-stats
