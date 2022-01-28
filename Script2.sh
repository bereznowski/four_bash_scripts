#!/bin/bash

CATALOG=""
NAME=""
LAST_CHANGE=""
MAX_DEPTH=""
SIZE=""
K="k"
CONTENT=""

OPTION_CATALOG=()
OPTION_NAME=()
OPTION_LAST_CHANGE=()
OPTION_MAX_DEPTH=()
OPTION_SIZE=()
OPTION_CONTENT=()

INTERFACE="
1. File name: $NAME
2. Catalog: $CATALOG
3. Last changed in less than (number of days): $LAST_CHANGE
4. Max depth (how many directories below the starting point can be accessed): $MAX_DEPTH
5. Size in kibibytes (less than): $SIZE 
6. File content: $CONTENT
7. Search
8. Finish

Choose a number:"

echo "$INTERFACE"

read OPTION

while [[ $OPTION -ne 8 ]]
do
	if [[ $OPTION -eq 1 ]]; then
		echo -e "\nFile name:"	
		read NAME
		if [[ -z "$NAME" ]]; then
			OPTION_NAME=()
		else
			OPTION_NAME=(-name "$NAME")
		fi
	elif [[ $OPTION -eq 2 ]]; then
		echo -e "\nCatalog:"
		read CATALOG
		if [[ -z "$CATALOG" ]]; then
			OPTION_CATALOG=()
		else
			OPTION_CATALOG=($CATALOG)
		fi
	elif [[ $OPTION -eq 3 ]]; then
		echo -e "\nFile was last changed in less than (number of days):"		
		read LAST_CHANGE
		if [[ -z "$LAST_CHANGE" ]]; then
			OPTION_LAST_CHANGE=()
		else
			OPTION_LAST_CHANGE=(-ctime -$LAST_CHANGE)
		fi
	elif [[ $OPTION -eq 4 ]]; then
		echo -e "\nMax depth (how many directories below the starting point can be accessed):"
		read MAX_DEPTH
		if [[ -z "$MAX_DEPTH" ]]; then
			OPTION_MAX_DEPTH=()
		else
			OPTION_MAX_DEPTH=(-maxdepth $MAX_DEPTH)
		fi
	elif [[ $OPTION -eq 5 ]]; then
		echo -e "\nFile size (in kibybytes):"
		read SIZE
		if [[ -z "$SIZE" ]]; then
			OPTION_SIZE=()
		else
			OPTION_SIZE=(-size -$SIZE$K)
		fi
	elif [[ $OPTION -eq 6 ]]; then
		echo -e "\nContent:"
		read CONTENT
		if [[ -z "$CONTENT" ]]; then
			OPTION_CONTENT=()
		else
			OPTION_CONTENT=(-exec grep -iH "$CONTENT" {} \;)
		fi
	elif [[ $OPTION -eq 7 ]]; then
		echo -e "\nResults:"
		find $OPTION_CATALOG "${OPTION_MAX_DEPTH[@]}" "${OPTION_NAME[@]}" "${OPTION_LAST_CHANGE[@]}" "${OPTION_SIZE[@]}" "${OPTION_CONTENT[@]}"
	else
		echo "Not an option"
	fi

INTERFACE="
1. File name: $NAME
2. Catalog: $CATALOG
3. Last changed in less than (number of days): $LAST_CHANGE
4. Max depth (how many directories below the starting point can be accessed): $MAX_DEPTH
5. Size in kibibytes (less than): $SIZE 
6. File content: $CONTENT
7. Search
8. Finish

Choose a number:"

	echo -e "\n---------------------------------------------------------------------------"

	echo "$INTERFACE"
	
	read OPTION

done

