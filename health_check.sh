#!/usr/bin/env bash

# Exit on errors, undefined variables, and failed commands in pipelines.
set -euo pipefail

# Optional output file supplied with -o.
OUTPUT_FILE=""

usage() {
    echo "Usage: $0 [-o output_file]"
    exit 1
}

# Parse command-line options.
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

# Generate the complete system health report.
generate_report() {

    echo "========================================"
    echo "System Health Check"
    echo "========================================"
    echo "Timestamp: $(date)"
    echo

    # ---------------- CPU Usage ----------------
    # Read CPU statistics from /proc/stat twice with a short delay.
    # Comparing two samples gives us the percentage of CPU time in use.
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

    # ---------------- Memory Usage ----------------
    # Display total, used, free, shared, cached and available RAM.
    echo "---------- Memory Usage ----------"
    free -m
    echo

    # ---------------- Root Disk Usage ----------------
    # Display human-readable root filesystem usage.
    echo "---------- Root Disk Usage ----------"
    df -h /
    echo

    # Extract the root filesystem usage percentage.
    DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

    # Warn when root disk usage exceeds 80%.
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "[WARNING] Root disk usage is above 80%: ${DISK_USAGE}%"
    else
        echo "[OK] Root disk usage: ${DISK_USAGE}%"
    fi

    echo

    # ---------------- Top Processes ----------------
    # Display the five processes currently using the most memory.
    echo "---------- Top 5 Memory-Consuming Processes ----------"
    ps aux --sort=-%mem | head -n 6
    echo

    # ---------------- Network Ports ----------------
    # Prefer ss because it is the modern replacement for netstat.
    # Fall back to netstat if ss is unavailable.
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

# Write the report to the requested file or directly to stdout.
if [ -n "$OUTPUT_FILE" ]; then
    generate_report >> "$OUTPUT_FILE"
    echo "Health report written to: $OUTPUT_FILE"
else
    generate_report
fi