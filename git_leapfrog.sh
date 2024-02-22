#!/bin/bash

# Prompt for the "since" date
read -p "Enter start date (YYYY-MM-DD): " since_date
while [ -z "$since_date" ]; do
    echo "Start date is required."
    read -p "Enter start date (YYYY-MM-DD): " since_date
done

# Prompt for the "until" date with default as today
read -p "Enter end date (YYYY-MM-DD) [default: $(date +%Y-%m-%d)]: " until_date
until_date=${until_date:-$(date +%Y-%m-%d)}

# Prompt for the branch name with default as "main"
read -p "Enter branch name [default: main]: " branch_name
branch_name=${branch_name:-main}

# Execute git log command with the provided or default parameters
git log --since="$since_date" --until="$until_date" --oneline --numstat $branch_name | \
awk '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1
    deleted+=$2
} END {
    print "Added lines: " added "\nDeleted lines: " deleted
}'
