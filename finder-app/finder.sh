#!/bin/sh

#The first argument is a path to a directory on the filesystem

filesdir=$1

#The second argument is a text string which will be searched within these files

searchstr=$2

if [ -z "$filesdir" ] || [ -z "$searchstr" ]
then
        echo "ERROR: Any of the parameters above were not specified"
        exit 1
fi

if ! [ -d "$filesdir" ]
then
	echo "ERROR: Filesdir does not represent a directory on the filesystem"
	exit 1
fi


# This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including 
# "i know that i may find the number of files using "find" and wc, so how can i use it ?".

commandFindAllFilesInDirectories=$(find "$filesdir" -type f | wc -l)

# This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including
# "examples of using grep" and " grep -rc "linux" using this command how to count all matching lines".

commandFindAllMatchingLines=$(grep -rc "$searchstr" "$filesdir" | awk -F: '{sum += $2} END {print sum}')

echo "The number of files are $commandFindAllFilesInDirectories and the number of matching lines are $commandFindAllMatchingLines"
