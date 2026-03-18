#!/bin/bash
# Latency Collection
# Target: AMD Ryzen 5600H (Isolated Cores 8,9,10,11)

# Detect Kernel and assign Scheduler label
KERNEL_VER=$(uname -r)
if dpkg --compare-versions "$KERNEL_VER" "ge" "6.6"; then
    SCHED_NAME="EEVDF"
else
    SCHED_NAME="CFS"
fi

CORES="8,9,10,11"
OUTPUT_CSV="dataset_${SCHED_NAME}.csv"
RUNS=50

# Hardcoding the path to the newest available perf binary
PERF_BIN="/usr/lib/linux-tools/6.17.0-19-generic/perf"

echo "Run_ID,Scheduler,Kernel,Avg_Latency_us,Max_Latency_us,Context_Switches,CPU_Migrations" > $OUTPUT_CSV
echo "Detected Kernel: $KERNEL_VER ($SCHED_NAME)"
echo "Using Perf Binary: $PERF_BIN"
echo "Starting $RUNS test runs on Cores $CORES"


for i in $(seq 1 $RUNS); do
    echo -n "Running sample $i/$RUNS... "

    # 1. Background load (Forced to isolated cores)
    taskset -c $CORES hackbench -p -l 2500 > /dev/null 2>&1 &
    HACK_PID=$!

    # 2. Perf (Bypassed) & Cyclictest
    $PERF_BIN stat -x, -o perf_temp.txt -e context-switches,cpu-migrations \
        cyclictest -m -p 99 -a $CORES -t 4 -i 1000 -l 10000 -q > cyclic_temp.txt

    # 3. Parse Data
    MAX_LAT=$(grep "Max:" cyclic_temp.txt | awk -F "Max:" '{print $2}' | awk '{print $1}' | sort -nr | head -n1)
    AVG_LAT=$(grep "Avg:" cyclic_temp.txt | awk -F "Avg:" '{print $2}' | awk '{print $1}' | sort -nr | head -n1)
    CSWITCH=$(grep "context-switches" perf_temp.txt | cut -d, -f1)
    MIGRATE=$(grep "cpu-migrations" perf_temp.txt | cut -d, -f1)

    # 4. Append to CSV
    echo "$i,$SCHED_NAME,$KERNEL_VER,$AVG_LAT,$MAX_LAT,$CSWITCH,$MIGRATE" >> $OUTPUT_CSV

    # Cleanup
    kill $HACK_PID 2>/dev/null
    wait $HACK_PID 2>/dev/null

    echo "Done (Max Latency: ${MAX_LAT}us)"
done

rm -f perf_temp.txt cyclic_temp.txt
echo "Data collection complete! Results saved to $OUTPUT_CSV"
