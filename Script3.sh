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

MENU=("File name" "Catalog" "Last change" "Max depth" "Size" "File content")
FINISH=123

while [[ $FINISH -ne 1 ]]
do
	if [[ "$RESPONSE" = "${MENU[0]}" ]]; then
		NAME=`zenity --entry --title "File name" --text "File name:"`
		if [[ -z "$NAME" ]]; then
			OPTION_NAME=()
		else
			OPTION_NAME=(-name "$NAME")
		fi
	elif [[ "$RESPONSE" = "${MENU[1]}" ]]; then
		CATALOG=`zenity --file-selection --directory`
		if [[ -z "$CATALOG" ]]; then
			OPTION_CATALOG=()
		else
			OPTION_CATALOG=($CATALOG)
		fi
	elif [[ "$RESPONSE" = "${MENU[2]}" ]]; then
		LAST_CHANGE=`zenity --entry --title "Last change" --text "Last changed in less than (number of days):"`
		if [[ -z "$LAST_CHANGE" ]]; then
			OPTION_LAST_CHANGE=()
		else
			OPTION_LAST_CHANGE=(-ctime -$LAST_CHANGE)
		fi
	elif [[ "$RESPONSE" = "${MENU[3]}" ]]; then
		MAX_DEPTH=`zenity --entry --title "Max depth" --text "Max depth (how many directories below the starting point can be accessed):"`
		if [[ -z "$MAX_DEPTH" ]]; then
			OPTION_MAX_DEPTH=()
		else
			OPTION_MAX_DEPTH=(-maxdepth $MAX_DEPTH)
		fi
	elif [[ "$RESPONSE" = "${MENU[4]}" ]]; then
		SIZE=`zenity --entry --title "Size" --text "Size in kibibytes (less than):"`
		if [[ -z "$SIZE" ]]; then
			OPTION_SIZE=()
		else
			OPTION_SIZE=(-size -$SIZE$K)
		fi
	elif [[ "$RESPONSE" = "${MENU[5]}" ]]; then
		CONTENT=`zenity --entry --title "File content:" --text "File content:"`
		if [[ -z "$CONTENT" ]]; then
			OPTION_CONTENT=()
		else
			OPTION_CONTENT=(-exec grep -iH "$CONTENT" {} \;)
		fi
	elif [[ $FINISH -eq 0 ]]; then
		find $OPTION_CATALOG "${OPTION_MAX_DEPTH[@]}" "${OPTION_NAME[@]}" "${OPTION_LAST_CHANGE[@]}" "${OPTION_SIZE[@]}" "${OPTION_CONTENT[@]}" | zenity --text-info --height 320 --width 960 --title "Matching files:"

	fi

	RESPONSE=`zenity --list --title "GUI for searching files" --text "Choose an option" \
	--column "Options:" --column "Currently selected" \
	"${MENU[0]}" "$NAME" \
	"${MENU[1]}" "$CATALOG" \
	"${MENU[2]}" "$LAST_CHANGE" \
	"${MENU[3]}" "$OPTION_MAX_DEPTH" \
	"${MENU[4]}" "$SIZE" \
	"${MENU[5]}" "$CONTENT" \
	--height 260 --width 320 \
	--cancel-label Finish \
	--ok-label Search`
	FINISH=$?
done


