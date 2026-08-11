#!/usr/bin/env bash


set -euo pipefail


OUTPUT_FILE=""

usage() {
    echo "Usage: $0 [-o output_file]"
    exit 1
}


while getopts ":o:" opt; do
    case "$opt" in
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done


generate_report() {

    echo "========================================"
    echo "System Health Check"
    echo "========================================"
    echo "Timestamp: $(date)"
    echo

   
    echo "---------- CPU Usage ----------"

    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat

    idle1=$((idle + iowait))
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))

    sleep 1

    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat

    idle2=$((idle + iowait))
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))

    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))

    if [ "$total_diff" -gt 0 ]; then
        CPU_USAGE=$((100 * (total_diff - idle_diff) / total_diff))
        echo "CPU Usage: ${CPU_USAGE}%"
    else
        echo "[WARNING] Unable to calculate CPU usage."
    fi

    echo


    echo "---------- Memory Usage ----------"
    free -m
    echo

   
    echo "---------- Root Disk Usage ----------"
    df -h /
    echo


    DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')


    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "[WARNING] Root disk usage is above 80%: ${DISK_USAGE}%"
    else
        echo "[OK] Root disk usage: ${DISK_USAGE}%"
    fi

    echo

    
    echo "---------- Top 5 Memory-Consuming Processes ----------"
    ps aux --sort=-%mem | head -n 6
    echo

  
    echo "---------- Listening Network Ports ----------"

    if command -v ss >/dev/null 2>&1; then
        ss -tuln
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln
    else
        echo "[WARNING] Neither ss nor netstat is installed."
    fi

    echo
    echo "========================================"
    echo "Health check completed."
    echo "========================================"
}

if [ -n "$OUTPUT_FILE" ]; then
    generate_report >> "$OUTPUT_FILE"
    echo "Health report written to: $OUTPUT_FILE"
else
    generate_report
fi