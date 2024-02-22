#!/bin/bash

# Calculate date one week ago from today for the default start date
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)

# Prompt for the "since" date with default as one week ago
read -p "Enter start date (YYYY-MM-DD) [default: $default_since_date]: " since_date
since_date=${since_date:-$default_since_date}

# Prompt for the "until" date with default as today
default_until_date=$(date +%Y-%m-%d)
read -p "Enter end date (YYYY-MM-DD) [default: $default_until_date]: " until_date
until_date=${until_date:-$default_until_date}

# Prompt for the branch name with default as "main"
read -p "Enter branch name [default: main]: " branch_name
branch_name=${branch_name:-main}

# Calculate the number of days between since_date and until_date
days=$(( ( $(date -d "$until_date" +%s) - $(date -d "$since_date" +%s) ) / 86400 + 1 ))

# Execute git log command with the provided or default parameters
git log --since="$since_date" --until="$until_date" --branches="$branch_name" --oneline --numstat $branch_name | \
awk -v days="$days" '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1
    deleted+=$2
    total+=($1+$2)
} END {
    print "✅ Added lines: " added "\n❌ Deleted lines: " deleted
    print "📊 Average lines changed per day: " (total/days)
}'
