#!/bin/bash

# Calculate default dates
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)
default_until_date=$(date +%Y-%m-%d)

# Prompt for the "since" date with default as one week ago
read -p "Enter start date (YYYY-MM-DD) [default: $default_since_date]: " since_date
since_date=${since_date:-$default_since_date}

# Prompt for the "until" date with default as today
read -p "Enter end date (YYYY-MM-DD) [default: $default_until_date]: " until_date
until_date=${until_date:-$default_until_date}

# Prompt for the branch name with default as "main"
read -p "Enter branch name [default: main]: " branch_name
branch_name=${branch_name:-main}

# Calculate the number of days between since_date and until_date, accounting for both dates being included
days=$(( ( $(date -d "$until_date" +%s) - $(date -d "$since_date" +%s) ) / 86400 + 1 ))

# Validate that days calculation doesn't result in an error
if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echo "Error calculating the number of days. Please check the entered dates."
    exit 1
fi

# Execute git log command with the provided or default parameters
git log --since="$since_date" --until="$until_date" --branches="$branch_name" --oneline --numstat $branch_name | \
awk -v days="$days" '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1
    deleted+=$2
    total+=($1+$2)
} END {
    print "✅ Added lines: " added "\n❌ Deleted lines: " deleted
    if (days > 0) {
        print "📊 Average lines changed per day: " (total/days)
    } else {
        print "📊 Average lines changed per day: Not applicable"
    }
}'
