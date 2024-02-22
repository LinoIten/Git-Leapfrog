#!/bin/bash

# Calculate default dates
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)
default_until_date=$(date +%Y-%m-%d)

echo "Default start date is one week ago: $default_since_date"
echo "Default end date is today: $default_until_date"
echo "Default branch name is 'main'."

# Prompt for the "since" date with information to use default
read -p "Enter start date (YYYY-MM-DD) or press Enter to use default [$default_since_date]: " since_date
since_date=${since_date:-$default_since_date}

# Prompt for the "until" date with information to use default
read -p "Enter end date (YYYY-MM-DD) or press Enter to use default [$default_until_date]: " until_date
until_date=${until_date:-$default_until_date}

# Prompt for the branch name with information to use default
read -p "Enter branch name or press Enter to use default [main]: " branch_name
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
    print "🔄 Added lines: " added "\n🗑️ Deleted lines: " deleted
    if (days > 0) {
        print "📅 Average lines changed per day: " (total/days)
    } else {
        print "📅 Average lines changed per day: Not applicable"
    }
}'
