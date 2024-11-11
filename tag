#!/bin/bash
commands=$(ls /usr/local/bin/tag-* | xargs basename)

for param in "$@"; do
    commands=$(echo "$commands" | grep "$param")
done

amount=$(echo "$commands" | wc -w)

if [ "$amount" -eq 0 ]; then
    echo "No matching commands"
    exit 1
fi

if [ "$amount" -gt 1 ]; then
    echo "$commands"
		exit 1
else
		# echo "Running: $commands"
    selected_command=$commands
fi

if cat "/usr/local/bin/$commands" | tag-scripts-takes-input > /dev/null; then
	if [[ -t 0 ]]; then
		echo "Enter input for the command (or press Enter to skip):"
	fi

	read input
fi

echo "Running $selected_command with input '$input'"

if [ -z "$input" ]; then
    $selected_command
else
		$selected_command "$input"
fi

