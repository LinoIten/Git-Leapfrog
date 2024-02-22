#!/bin/bash

# Set default dates
default_since_date=$(date -d "1 week ago" +%Y-%m-%d)
default_until_date=$(date +%Y-%m-%d)
default_branch_name="main"

# Function to show prompts with default values
prompt_with_default() {
    local prompt_message="$1"
    local default_value="$2"
    local user_input

    echo -ne "$prompt_message [$default_value]: "
    read user_input

    if [[ -z "$user_input" ]]; then
        echo "$default_value" # User pressed enter, use default
    else
        echo "$user_input" # Use the user-provided input
    fi
}

# Collect inputs with defaults
since_date=$(prompt_with_default "Enter start date (YYYY-MM-DD)" $default_since_date)
until_date=$(prompt_with_default "Enter end date (YYYY-MM-DD)" $default_until_date)
branch_name=$(prompt_with_default "Enter branch name" $default_branch_name)

# Calculate the number of days between since_date and until_date, including both dates
days=$(( ( $(date -d "$until_date" +%s) - $(date -d "$since_date" +%s) ) / 86400 + 1 ))

# Validate days calculation
if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    echo "Error in date calculation. Please check the entered dates."
    exit 1
fi

# Execute git log command and process its output
git log --since="$since_date" --until="$until_date" --branches="$branch_name" --oneline --numstat $branch_name | \
awk -v days="$days" '
$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
    added+=$1;
    deleted+=$2;
    total+=($1+$2);
} 
END {
    print "\n🌟 Added lines: " added "\n🗑️ Deleted lines: " deleted;
    if (days > 0) {
        print "📊 Average lines changed per day: " (total/days);
    } else {
        print "📊 Average lines changed per day: Not applicable";
    }
}'