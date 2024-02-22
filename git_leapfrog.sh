#!/bin/bash
# Calculate default dates
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)
default_until_date=$(date +%Y-%m-%d)

# Function to prompt with default value
prompt_with_default() {
    local prompt=$1
    local default=$2
    local result

    # Use read with a timeout to "preload" default value into the buffer
    read -p "$prompt" -e -i "$default" -t 1 result
    # Clear the line (in case of timeout, the default value is shown partially)
    echo -en "\r\033[K"
    # Prompt again for user input
    read -p "$prompt" -e -i "$default" result
    echo $result
}

# Prompt for dates and branch with defaults
since_date=$(prompt_with_default "Enter start date (YYYY-MM-DD): " $default_since_date)
until_date=$(prompt_with_default "Enter end date (YYYY-MM-DD) [default: $default_until_date]: " $default_until_date)
branch_name=$(prompt_with_default "Enter branch name [default: main]: " "main")

# Calculate the number of days between since_date and until_date
days=$(( ( $(date -d "$until_date" +%s) - $(date -d "$since_date" +%s) ) / 86400 + 1 ))

# Execute git log command
git log --since="$since_date" --until="$until_date" --branches="$branch_name" --oneline --numstat $branch_name | \
awk -v days="$days" '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1
    deleted+=$2
    total+=($1+$2)
} END {
    print "✅ Added lines: " added "\n❌ Deleted lines: " deleted
    print "📊 Average lines changed per day: " (total/days)
}'
