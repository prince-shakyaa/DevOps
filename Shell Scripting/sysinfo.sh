#!/bin/bash
# DevOps Practical Assignment
# Author: Student

current_date=$(date)
machine_nacurrent_user=$(hostname)
current_user=$(whoami)
disk=$(df -h / | awk 'NR==2 {print $5 " used of " $2}')
proc_count=$(ps aux | wc -l | tr -d ' ')

echo "=== System summary ==="
echo "Date        : $current_date"
echo "Host        : $machine_name"
echo "User        : $current_user"
echo "Root disk   : $disk"
echo "Processes   : $proc_count running"
echo

echo "--- Disk usage (df -h) ---"
df -h
echo

echo "--- Top 10 processes by CPU ---"
ps aux | sort -rk 3 | head -n 10 | cut -c1-110
echo

read -p "Directory to save the report in: " output_directory
read -p "Report file name: " output_filename

mkdir -p "$output_directory"
touch "$output_directory/$output_filename"

# Full process list goes to the file with > redirection
ps aux > "$output_directory/$output_filename"

echo
echo "Saved $(wc -l < "$output_directory/$output_filename" | tr -d ' ') lines of process data to $output_directory/$output_filename"
