#!/bin/bash

# This script is *NOT* meant to be run directly. It is a hint to process output
# data from experiments for various outputs.

# Get the final compilation time from each run of a specific enterprise network:
cd ~/pyretic/pyretic/evaluations/evaluation_results/nsdi16
network="purdue"
for q in `echo tm congested_link path_loss slice ddos firewall`; do
    for cnt in `seq 1 5`; do
	grep -H 'total time' ${q}_${network}_fdd_${cnt}/stat.txt | awk '{print $1 " " $4}' | sort -nk2 | tail -1
    done
done

# --> should output 30 numbers, corresponding to each trial (5) of each query
# (6). It is easy to generate per-query medians/averages and global averages
# (across 30 runs) from this.

####################

# Printing the maximum in_table rule count numbers
cd ~/pyretic/pyretic/evaluations/evaluation_results/nsdi16
network="purdue"
for q in `echo tm congested_link path_loss slice ddos firewall`; do
    grep -H 'in_table' ${q}_${network}_fdd_1/stat.txt | grep '))' | awk '{print $3}' | sed 's/.$//' | awk '{ total += $1; count++ } END { print total " " count }'
done

# ... should print the *SUM* of the max rule counts over stages for each query,
# as well as the number of stages for each query. You should see 6 lines in the
# same order as the query list in the for loop.

# same could be done for out_table counts.

####################

# getting log values from the command line
val=138; python -c "import math; print int(math.ceil(math.log($val,2)))"

# to get sum of log of an array of numbers, do
val="64 56 129"; python -c "import math; sum=reduce(lambda acc, x: acc + int(math.ceil(math.log(int(x), 2))), \"${val}\".split(), 0); print sum"

# now use that to get total number of state bits for each network/query
network="berkley"
for q in `echo tm congested_link path_loss slice ddos firewall`; do
    do val=`grep -H 'state count' ${q}_${network}_fdd_1/stat.txt | awk '{printf("%s ", $4)'}`;
    python -c "import math; sum=reduce(lambda acc, x: acc + int(math.ceil(math.log(int(x),2))), \"${val}\".split(), 0); print sum";
done

# this should print 6 numbers for each query for that network, in the same order
# as looped.


####################
# More processing hints for averages of multiple topologies and queries
# ("scalability trend" graphs)

# get compile times for each topology size, averaging across the different
# topologies and query runs.
for i in `echo 20 40 60 80 100 120 140 160`; do for test in `echo igen_delauney waxman_03_03 waxman_02_04 waxman_04_02 waxman_05_015`; do for query in `echo tm congested_link path_loss slice ddos firewall`; do grep -H 'total time' ${query}_${test}_${i}_fdd_1/stat.txt | awk '{print $1 " " $4}' | sort -nk2 | tail -1; done ; done | awk -v prefix=$i '{total += $2; count++} END { print prefix " " total/count " " count }'  ; done 2>/dev/null

# get rule count for in_table, averaged
for i in `echo 20 40 60 80 100 120 140 160`; do for test in `echo igen_delauney waxman_03_03 waxman_02_04 waxman_04_02 waxman_05_015`; do for query in `echo tm congested_link path_loss slice ddos firewall`; do grep -H 'in_table' ${query}_${test}_${i}_fdd_1/stat.txt | grep '))' | sed '/^S/d' | awk '{print $1 " " $3}' | sed 's/.$//' | awk '{ total += $2 ; count++ } END { print $1 " " total " " count }' ; done ; done  | sed '/^\s\s$/d' | awk -v prefix=$i '{ total += $2; count++ } END { print prefix " " total/count }' ; done 2>/dev/null

# get state count, averaged
for i in `echo 20 40 60 80 100 120 140 160`; do for test in `echo igen_delauney waxman_03_03 waxman_02_04 waxman_04_02 waxman_05_015`; do for query in `echo tm congested_link path_loss slice ddos firewall`; do val=`grep -H 'state count' ${query}_${test}_${i}_fdd_1/stat.txt | awk '{printf("%s ", $4)}' ` ; python -c "import math; sum=reduce(lambda acc,x: acc + int(math.ceil(math.log(int(x),2))), \"${val}\".split(), 0); print sum" ; done ; done | awk -v prefix=$i ' { if ( $1 > 0 ) { total += $1; count++ } } END { print prefix " " total/count " " count }' ; done 2>/dev/null
