#!/bin/bash
commands=$(ls /usr/local/bin/tag-* | xargs -I{} basename {})

filter_params=()
input_params=()
taking_input=false

verbose=false
quiet=false
as_source=false

show_help() {
		echo "Usage: $0 [OPTIONS] FILTER_PARAMS [-i|--input INPUT_PARAMS]"
    echo
    echo "Options:"
    echo "  -i, --input               Mark the start of filter parameters"
    echo "  -v, --verbose             Enable verbose output"
    echo "  -q, --quiet               Suppress output of selected command"
    echo "  -s, --source              Prefix selected command with 'source'"
    echo "  -h, --help                Show this help message and exit"
    echo
    echo "FILTER_PARAMS are used to select which command to run."
    echo "INPUT_PARAMS are the parameters to pass to the selected command."
    echo
}

for param in "$@"; do
	if [ "$taking_input" = true ]; then
		input_params+=("$param")
	elif [ "$param" = "-h" ] || [ "$param" = "--help" ]; then
		show_help
		exit 0
	elif [ "$param" = "-i" ] || [ "$param" = "--input" ]; then
		taking_input=true
	elif [ "$param" = "-v" ] || [ "$param" = "--verbose" ]; then
		verbose=true
	elif [ "$param" = "-q" ] || [ "$param" = "--quiet" ]; then
		quiet=true
	elif [ "$param" = "-s" ] || [ "$param" = "--source" ]; then
		as_source=true
	else
		filter_params+=("$param")
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

if cat "/usr/local/bin/$commands" | tag-scripts-takes-input > /dev/null && [ "$taking_input" = false ] ; then
	echo "ERROR: Command expects input but none was found"
	exit 1
fi

prefix=""
if [ "$as_source" = true ]; then
	prefix="source"
fi

if [ "$quiet" = true ]; then
	$prefix $commands "${input_params[@]}" > /dev/null 2>&1 &
else
	$prefix $commands ${input_params[@]}
fi

