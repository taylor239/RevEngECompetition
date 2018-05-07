#!/bin/bash

echo $1
echo $2

rm $2
echo "" > $2

closeparen=false
while read -r line; do
	if [[ $line = "struct timeval;"* ]]; then
		echo "Found struct timeval;: $line"
	elif [[ $line = "struct timeval"* ]]; then
		echo "Found struct timeval: $line"
		closeparen=true
	elif [[ $line = "extern"* ]]; then
		echo "Found extern: $line"
	elif [ "$closeparen" = true ]; then
		echo "Waiting for close paren: $line"
		if [[ $line = *"};" ]]; then
			closeparen=false;
		fi
	else
		echo "Keeping $line"
		echo "$line" >> $2
	fi
done <$1

