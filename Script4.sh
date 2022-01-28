#!/bin/bash

# Author		: Piotr Bereznowski (s155028@student.pg.edu.pl)
# Created On		: 08/12/2021
# Last Modified By 	: Piotr Bereznowski (s155028@student.pg.edu.pl)
# Last Modified On	: 18/01/2022
# Version		: 1.0
#
# Description		: This is a simple script for creating scheduled backups. It uses cron for backup creation and zenity for GUI.
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more
# details or contact the Free Software Foundation for a copy)

###################################################################################################################
#
# variables
#
###################################################################################################################

# these variables are used for storing paths to directory to backup and directory with backups
DIRECTORY_TO_BACKUP=""
BACKUP_DIRECTORY=""

# these variables are used as cron arguments
MINUTES="*"
HOURS="*"
DAYS_OF_MONTH="*"
MONTHS="*"
DAYS_OF_WEEK="*"

# these variables are used to keep previous values of the variable above
# by default they all are set to * which means that they take all possible values
MINUTES_PREVIOUS="*"
HOURS_PREVIOUS="*"
DAYS_OF_MONTH_PREVIOUS="*"
MONTHS_PREVIOUS="*"
DAYS_OF_WEEK_PREVIOUS="*"

# these variables are used to handle main window
MENU=("Minutes" "Hours" "Days of month" "Months" "Days of week")
START=123
FINISH=123

###################################################################################################################
#
# functions
#
###################################################################################################################

displayHelp(){
	echo -e "This script uses zenity to create a user-friendly GUI for creating scheduled backups. \
	
	\nFirstly, you are asked to choose which directory would you like to backup. \
	\nSecondly, you are asked where to backup this directory. \
	\nFinally, you are asked how often to backup. \

	\nThis script uses numbers, asterisks (*), hypens (-), and commas (,) in the same way as cron. \
	In case of any ambiguity, please see cron manual."
}

displayVersion(){
	echo "GUI for cron 1.0"
}
# this function displays the main window in which user is informed how to use the script in details
displayMainWindow(){
RESPONSE=`zenity --list --title "Cron parameters" \
	--text "How often would you like to backup? \

	\nFor minutes, hours, days of month, and months you can input numbers and three symbols: \
	\nasterisk (*), hypen (-), and comma (,) \

	\n (*) asterisk corresponds to every value of given parameter, \
	\n (-) hypen corresponds to a range of values, \
	\n (,) comma corresponds to list of values. \
	
	\nIn case of any problems with these symbols please see cron manual. \

	\nFor days of week you can check on which days of week you would like to create backups." \
	--column "Time parameters:" --column "Currently selected" \
	"${MENU[0]}" "$MINUTES" \
	"${MENU[1]}" "$HOURS" \
	"${MENU[2]}" "$DAYS_OF_MONTH" \
	"${MENU[3]}" "$MONTHS" \
	"${MENU[4]}" "$DAYS_OF_WEEK" \
	--height 450 \
	--width 400 \
	--cancel-label Cancel \
	--ok-label Backup`

	FINISH=$?
}

# this function displays an error message when user provides input which does not match regular expression for the given argument
displayError(){
zenity --error \
--title "Error Message" \
--text "You provided an invalid input. Please try again." \
--width 400 \
--height 50
}

# each of the four functions below work in the same way
# 1. User is asked to provide input.
# 2. If user did not provide any input, then the script keeps the previous input.
# 3. If user provided an invalid input, then error message is displayed and the script keeps the previous input.
# 4. If user provided a valid input, then the new input is kept.

handleMinutes(){
	MINUTES=`zenity --entry --title "Backup minutes" --text "On which minutes would you like to create backups?"`
	if [[ -z "$MINUTES" ]]; then
		MINUTES=$MINUTES_PREVIOUS
	elif [[ $MINUTES =~ (^[*]|^[0-9]|^[0-5][0-9]){1}(([,]([0-9]|[0-5][0-9]))*|([-]([0-9]|[0-5][0-9])){1})$ ]]; then
		MINUTES_PREVIOUS=$MINUTES
	else
		MINUTES=$MINUTES_PREVIOUS
		displayError
	fi
}

handleHours(){
	HOURS=`zenity --entry --title "Backup hours" --text "On which minutes would you like to create backups?"`
	if [[ -z "$HOURS" ]]; then
		HOURS=$HOURS_PREVIOUS
	elif [[ $HOURS =~ (^[*]|^[0-9]|^[0-1][0-9]|^[2][0-3]){1}(([,]([0-9]|[0-1][0-9]|[2][0-3]))*|([-]([0-9]|[0-1][0-9]|[2][0-3])){1})$  ]]; then
		HOURS_PREVIOUS=$HOURS
	else
		HOURS=$HOURS_PREVIOUS
		displayError
	fi
}

handleDaysOfMonth(){
	DAYS_OF_MONTH=`zenity --entry --title "Backup days of month" --text "On which days of month would you like to create backups?"`
	if [[ -z "$DAYS_OF_MONTH" ]]; then
		DAYS_OF_MONTH=$DAYS_OF_MONTH_PREVIOUS
	elif [[ $DAYS_OF_MONTH =~ (^[*]|^[0-9]|^[1-2][0-9]|^[3][0-1]){1}(([,]([0-9]|[1-2][0-9]|[3][0]))*|([-]([0-9]|[1-2][0-9]|[3][0-1])){1})$  ]]; then
		DAYS_OF_MONTH_PREVIOUS=$DAYS_OF_MONTH
	else
		DAYS_OF_MONTH=$DAYS_OF_MONTH_PREVIOUS
		displayError
	fi
}

handleMonths(){
	MONTHS=`zenity --entry --title "Backup months" --text "On which months would you like to create backups?"`
	if [[ -z "$MONTHS" ]]; then
		MONTHS=$MONTH_PREVIOUS
	elif [[ $MONTHS =~ (^[*]|^[0-9]|^[1][0-2]){1}(([,]([0-9]|[1][0-2]))*|([-]([0-9]|[1][0-2])){1})$  ]]; then
		MONTHS_PREVIOUS=$MONTHS
	else
		MONTHS=$MONTH_PREVIOUS
		displayError
	fi
}

# this function allows user to check on which days of the week backups should be created
# then it replaces all vertical bars (|) with commas (,) to match cron formatting
# if user unchecked all days of the week an appropriate error message is displayed and the script keeps previous input

handleDaysOfWeek(){
	DAYS_OF_WEEK=`zenity \
	--list \
	--checklist \
	--column "Backup" \
	--column "Week day" \
	TRUE SUN \
	TRUE MON \
	TRUE TUE \
	TRUE WED \
	TRUE THU \
	TRUE FRI \
	TRUE SAT \
	--height 300`

	DAYS_OF_WEEK=`echo $DAYS_OF_WEEK | sed "s/|/,/g"`


	if [[ -z "$DAYS_OF_WEEK" ]]; then
		zenity --error --text "You did not select any days of week!"
		DAYS_OF_WEEK=$DAYS_OF_WEEK_PREVIOUS
	else
		DAYS_OF_WEEK_PREVIOUS=$DAYS_OF_WEEK
	fi
}

# this function handles navigation of the script
handleMenu(){

	if [[ "$RESPONSE" = "${MENU[0]}" ]]; then
		handleMinutes
	elif [[ "$RESPONSE" = "${MENU[1]}" ]]; then
		handleHours
	elif [[ "$RESPONSE" = "${MENU[2]}" ]]; then
		handleDaysOfMonth
	elif [[ "$RESPONSE" = "${MENU[3]}" ]]; then
		handleMonths
	elif [[ "$RESPONSE" = "${MENU[4]}" ]]; then
		handleDaysOfWeek
	elif [[ $FINISH -eq 0 ]]; then
		# this command modifies crontab
		echo "$MINUTES $HOURS $DAYS_OF_MONTH $MONTHS $DAYS_OF_WEEK tar -zcpf $BACKUP_DIRECTORY/$(basename $DIRECTORY_TO_BACKUP).tar $DIRECTORY_TO_BACKUP" | crontab
		FINISH=1
	fi

}

###################################################################################################################
#
# main part of the script
#
###################################################################################################################

# display help and version informations
while getopts hv OPT; do
	case $OPT in
		h) displayHelp
		START=1;;
		v) displayVersion
		START=1;;
		*) echo "Unknown option!"
		START=1;;
	esac
done

# this part of the script is only run when user did not ask about help or version
if [[ START -ne 1 ]]; then
	# it displays window with basic informations about this script
	zenity  --info --title "GUI for directory backup with cron" \
		--text "This is a GUI for directory backup with cron. \
		\nPlease chose a directory to backup and place for the backups." \
		--height 50 --width 400

	# these two lines asks user which directory to backup and where to back it up
	DIRECTORY_TO_BACKUP=`zenity --file-selection --directory --filename=/home/$USER/ --title="Select a directory to backup"`
	BACKUP_DIRECTORY=`zenity --file-selection --directory --filename=/home/$USER/ --title="Select a directory where you would like to create a backup"`

	# this is the main loop of the script
	# it handles user inputs and displays main window with all cron parameters

	while [[ $FINISH -ne 1 ]]
	do
		displayMainWindow
		handleMenu
	done
fi