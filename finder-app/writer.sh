#!/bin/bash

#The first argument is a full path to a file (including filename) on the filesystem

writefile=$1

#The second argument is a text string which will be written within this file

writestr=$2

if [ -z "$writefile" ] || [ -z "$writestr" ] 
then
	echo "ERROR: Any of the arguments above were not specified"
	exit 1
fi


# This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including 
# "look if i have to create new file in new directories how can i do this one command and in bash" and "path i have is in one variable".
 
if ! [ -d "$writefile" ]
then
	findDirectory=$(dirname "$writefile")
	mkdir -p "$findDirectory"
fi

echo "$writestr" > "$writefile"

# This function was fully  generated using ChatGPT at https://chat.openai.com/ with prompts including
# "how check if file could not be created".

if ! [ $? -eq 0 ] 
then
    echo "ERROR: The file can not be created"
    exit 1
fi

