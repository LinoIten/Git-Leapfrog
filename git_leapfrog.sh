#!/bin/bash

# Calculate default dates
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)
default_until_date=$(date +%Y-%m-%d)

# Prompt for the "since" date with default as one week ago
read -p "🌞 Since  [$default_since_date]: " since_date
since_date=${since_date:-$default_since_date}

# Prompt for the "until" date with default as today
read -p "🌚 Until  [$default_until_date]: " until_date
until_date=${until_date:-$default_until_date}

# Prompt for the branch name with default as "main"
read -p "🌲 Branch [main]: " branch_name
branch_name=${branch_name:-main}

# Calculate the number of days between since_date and until_date
days=$(( ($(date -d "$until_date" +%s) - $(date -d "$since_date" +%s)) / 86400 + 1 ))

# Check for valid days calculation
if [ "$days" -le 0 ]; then
    echo "Error: 'until_date' must be after 'since_date'."
    exit 1
fi

# Execute git log command with the provided or default parameters
git log --since="$since_date" --until="$until_date" --branches="$branch_name" --oneline --numstat $branch_name | \
awk -v days="$days" '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1
    deleted+=$2
} END {
    print "\nFrom " "'$since_date'" " to " "'$until_date'" " (" days " days)\n"
    print "🔵 Added lines: " added
    print "🔴 Deleted lines: " deleted "\n"
    if (days > 0) {
        print "🚀 Average lines changed per day: " (added+deleted)/days
    }

    print "\n summarized by 🐸 Git Leapfrog"
}'