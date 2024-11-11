#!/bin/bash
commands=$(ls /usr/local/bin/tag-* | xargs -I{} basename {})

filter_params=()
input_params=()

done_filter=false
verbose=false
quiet=false

for param in "$@"; do
	if [ $param = '-i' ]; then
		done_filter=true
	elif [ $param = '-v' ]; then
		verbose=true
	elif [ $param = '-q' ]; then
		quiet=true
	elif [ "$done_filter" = false ]; then
		filter_params+=("$param")
	else
		input_params+=("$param")
	fi
done

if [ ${#filter_params[@]} -eq 0 ]; then
	if [ ${#input_params[@]} -ne 0 ]; then
		echo "ERROR: No filter params found"
	fi
	echo "$commands"
	exit 1
fi

done=false
for param in "${filter_params[@]}"; do
	if [ "$done" = true ]; then
		if [ "$verbose" = true ]; then
			echo "WARNING: You have extra filter params"
		fi
		break
	fi

	commands=$(echo "$commands" | grep $param)
	amount=$(echo "$commands" | wc -w)

	if [ $amount -eq 1 ]; then
		done=true
	fi
done

if [ $amount -gt 1 ]; then
	echo "ERROR: You need more filter params"
	echo "$commands"
	exit 1
fi

if [ $amount -eq 0 ]; then
	echo "ERROR: No command matches your filter params"
	exit 1
fi

if [ "$verbose" = true ]; then
	echo "Selected command: $commands"
	echo "Input params: ${input_params[@]}"
fi

if cat "/usr/local/bin/$commands" | tag-scripts-takes-input > /dev/null && [ "$done_filter" = false ] ; then
	echo "ERROR: Command expects input but none was found"
	exit 1
fi

if [ "$quiet" = true ]; then
	$commands "${input_params[@]}" > /dev/null 2>&1 &
else
	$commands ${input_params[@]}
fi

