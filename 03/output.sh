#!/bin/bash

source input.sh

# Удаление по лог файлу
function log_remove() {
    log_path="/home/kishabro/Downloads/02/report.log"

    while IFS= read -r line; do
        if [[ ! "$line" == *"SIZE"* ]]; then
            local file_path=$(echo "$line" | awk '{print $2}' | sed 's/,$//')
            rm -R "$file_path"
        fi
    done < "$log_path"
}

# Удаление по дате и времени создания
function dt_remove() {
    echo -n "Enter the start time of the view YYYY-MM-DD HH:MM: "
    read -r start_time
    echo -n "Enter the end time of the view YYYY-MM-DD HH:MM: "
    read -r end_time

    if ! start_epoch=$(date -d "$start_time" +%s 2> /dev/null); then
        echo "Error: invalid start time format."
        return 1
    fi

    if ! end_epoch=$(date -d "$end_time" +%s 2> /dev/null); then
        echo "Error: invalid end time format."
        return 1
    fi

    if [ "$start_epoch" -ge "$end_epoch" ]; then
        echo "Error: start time must be earlier than end time."
        return 1
    fi

    log_path="/home/kishabro/Downloads/02/report.log"
    if [ ! -f "$log_path" ]; then
        echo "Error: report.log not found in $log_path."
        return 1
    fi

    mapfile -t log_paths < <(sed -n 's/^PATH: \([^,]*\),.*/\1/p' "$log_path" | sort -u)

    if [ "${#log_paths[@]}" -eq 0 ]; then
        echo "No paths recorded in report.log."
        return 0
    fi

    removed_count=0
    for item_path in "${log_paths[@]}"; do
        # Skip if the path currently does not exist
        if [ ! -e "$item_path" ]; then
            continue
        fi

        item_epoch=$(stat -c %Y "$item_path" 2> /dev/null)
        if [ -z "$item_epoch" ]; then
            continue
        fi

        if [ "$item_epoch" -ge "$start_epoch" ] && [ "$item_epoch" -le "$end_epoch" ]; then
            rm -rf -- "$item_path"
            removed_count=$((removed_count + 1))
        fi
    done

    if [ "$removed_count" -eq 0 ]; then
        echo "No files or directories matched the specified time range."
    else
        echo "Removed $removed_count items listed in report.log."
    fi
}

# Удаление по маске и имени (т. е. символы, нижнее подчёркивание и дата)
function nm_remove() {
    read -p "Enter mask name (for example: a*b*z_191125): " mask_name
    n=1
    find / -name "$mask_name" -type d 2> /dev/null | grep -v -E "(/bin|/sbin)" | \
    while IFS= read -r name_path; do
        rm -R "$name_path"
    done
}