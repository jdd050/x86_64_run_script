#!/bin/sh

# $1 == SOURCE_FILE
# $2 == OUTPUT_NAME

SCRIPT_DIR="$( cd "$( dirname "$0")" && pwd )"
OUTPUT_NAME="$2"

if [ $# -eq 2 ] 
then
    if [ -e "$1" ]
    then
        SOURCE_FILE="$1"
    else
        echo "One or both files do not exist."
        exit 1
    fi
elif [ $# -lt 2 ]
then
    echo "Insufficient arguments provided. Need SOURCE_FILE, OUTPUT_NAME."
    exit 1
elif [ $# -gt 2 ]
then
    echo "Too many arguments provided. Only need SOURCE_FILE, OUTPUT_NAME."
    exit 1
fi

# assemble and link source file
as "$SOURCE_FILE" -o "$OUTPUT_NAME.o"
gcc -o "$OUTPUT_NAME" "$OUTPUT_NAME.o" -nostdlib -static
# run binary and display relevant information
"$SCRIPT_DIR/$OUTPUT_NAME" & 
TASK_PID=$!
wait $TASK_PID
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    # check if the exit code indicates a signal termination
    if [ $EXIT_CODE -ge 128 ]; then
        SIGNAL=$((EXIT_CODE - 128))
        echo "PID: $TASK_PID \nExit code: $EXIT_CODE (terminated by signal $SIGNAL)"
    else
        echo "PID: $TASK_PID \nExit code: $EXIT_CODE"
    fi
else
    echo "PID: $TASK_PID \nExit code: $EXIT_CODE (success)"
fi
