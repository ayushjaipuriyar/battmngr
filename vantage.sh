#!/bin/bash
#
# Read/Set battery modes in lenovo ideapad 15are05 using acpi_call kernel module

## Usage: vantage [OPTION] MODE
## Options:
##	-r, --read		read current battery mode
##	-s, --set		set battery mode
##	-rc, --read-charge	read current charge mode
##	-sc, --set-charge	set charge mode
## Battery modes:
##	1	Intelligent Cooling
##	2	Extreme Performance
##	3	Battery Saving
##
## Charge modes:
##	1	Rapid Charge On
##	2	Rapid Charge Off
##	3	Battery Conservation On
##	4	Battery Conservation Off
##
## Examples:
## 	vantage -r
## 	vantage -s 1
##	vantage -rc
##	vantage -sc 1
##	vantage -s 1 -r -sc 4 -rc

#######################################
# Print error messages to STDERR.
# Globals:
#   None
# Arguments:
#   Error message
# Outputs:
#   Writes error message to STDERR
#######################################
err() {
	echo "$*" >&2
}

#######################################
# Print usage message.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes usage message to STDOUT
#######################################
usage() {
	printf '%s\n' \
		"" \
		"Usage: vantage [OPTION...] MODE" \
		"Options:" \
		"        -r, --read             read current battery mode" \
		"        -s, --set              set battery mode" \
		"        -rc, --read-charge     read current charge mode" \
		"        -sc, --set-charge      set charge mode" \
		"Battery Modes:" \
		"        1        Intelligent Cooling" \
		"        2        Extreme Performance" \
		"        3        Battery Saving" \
		"Charge modes:" \
		"        1        Rapid Charge On" \
		"        2        Rapid Charge Off" \
		"        3        Battery Conservation On" \
		"        4        Battery Conservation Off" \
		"Examples:" \
		"        vantage -r " \
		"        vantage -s 1" \
		"        vantage -rc" \
		"        vantage -sc 1" \
		"        vantage -s 1 -r -sc 4 -rc"
}

#######################################
# Handle error messages and calls err function to print these.
# Globals:
#   None
# Arguments:
#   Error code
# Outputs:
#   None
#######################################
function error() {
	case $1 in

	0)
		err "Please provide a valid battery mode to set (only 1,2 and 3 are valid values)"
		usage
		;;

	1)
		err "Please provide a valid battery charge mode to set (only 1,2,3 and 4 are valid values)"
		usage
		;;

	2)
		err "Can't update the battery mode, please retry"
		;;

	3)
		err "Can't update the battery charge mode, please retry"
		;;

	4)
		err "Unrecognized battery mode, please retry"
		;;

	5)
		err "Unrecognized battery charge mode, please retry"
		;;

	7)
		err "Unrecognized operation"
		usage
		;;

	8)
		err "Please specify an operation"
		usage
		;;

	9)
		err "Unexpected error"
		;;

	10)
		err "Please invoke this script using sudo"
		;;

	*)
		err "Unknown error"
		;;
	esac

	exit 1
}

#######################################
# Check if the script is called using sudo.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function check_sudo() {
	if (($(id -u) != 0)); then
		error 10
	fi
}

#######################################
# Mount acpi_call module.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function setup() {
	modprobe acpi_call
}

#######################################
# Reads the current charge mode and
# check if it's equal to the expected one.
# Globals:
#   None
# Arguments:
#   Mode to check (0 = Rapid Charge, 1 = Battery conservation)
#   Expected mode code
# Outputs:
#   None
#######################################
function check_charge_mode() {
	# if we are checking rapid charge mode
	if (($1 == 0)); then
		echo '\_SB.PCI0.LPC0.EC0.FCGM' >/proc/acpi/call
		check=$(cat /proc/acpi/call | cut -d '' -f1)

	# if we are checking battery conservation mode
	elif (($1 == 1)); then
		echo '\_SB.PCI0.LPC0.EC0.BTSG' >/proc/acpi/call
		check=$(cat /proc/acpi/call | cut -d '' -f1)
	else
		# unexpected error!
		error 9
	fi
}

#######################################
# Set battery mode
# Globals:
#   None
# Arguments:
#   Battery mode code (1,2,3)
# Outputs:
#   None
#######################################
function set_operation() {
	case $1 in

	1)
		# Intelligent Cooling
		echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' >/proc/acpi/call
		;;

	2)
		# Extreme Performance
		echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' >/proc/acpi/call
		;;

	3)
		# Battery Saving
		echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' >/proc/acpi/call
		;;

	*)
		error 9
		;;
	esac
}

#######################################
# Set battery charge mode
# Globals:
#   None
# Arguments:
#   Battery mode code (1,2,3,4)
# Outputs:
#   None
#######################################
function set_charge_operation() {
	case $1 in

	1)
		# Rapid Charge On
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' >/proc/acpi/call
		check_charge_mode 0 "0x1"
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' >/proc/acpi/call
		check_charge_mode 1 "0x0"

		;;

	2)
		# Rapid Charge Off
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' >/proc/acpi/call
		check_charge_mode 0 "0x0"
		;;

	3)
		# Battery Conservation On
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' >/proc/acpi/call
		check_charge_mode 1 "0x1"
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' >/proc/acpi/call
		check_charge_mode 0 "0x0"
		;;

	4)
		# Battery Conservation Off
		echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' >/proc/acpi/call
		check_charge_mode 1 "0x0"
		;;

	*)
		error 9
		;;
	esac

}

#######################################
# Read battery mode
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Print battery mode name on STDOUT
#######################################
function read_operation() {
	echo '\_SB.PCI0.LPC0.EC0.STMD' >/proc/acpi/call
	check=$(cat /proc/acpi/call | cut -d '' -f1)

	echo '\_SB.PCI0.LPC0.EC0.QTMD' >/proc/acpi/call
	check2=$(cat /proc/acpi/call | cut -d '' -f1)
	case $check in

	"0x0")
		case $check2 in
		"0x0")
			echo "Extreme Performance"
			;;

		"0x1")
			echo "Battery Saving"
			;;
		esac
		;;

	"0x1")
		echo "Intelligent Cooling"
		;;

	*)
		error 4
		;;
	esac

}

#######################################
# Read battery charge mode
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Print battery charge mode names on STDOUT
#######################################
function read_charge_operation() {
	# rapid charge check
	echo '\_SB.PCI0.LPC0.EC0.FCGM' >/proc/acpi/call
	check=$(cat /proc/acpi/call | cut -d '' -f1)

	case $check in

	"0x0")
		echo "Rapid Charge Off"
		;;

	"0x1")
		echo "Rapid Charge On"
		;;

	*)
		error 5
		;;
	esac

	# battery conservation check
	echo '\_SB.PCI0.LPC0.EC0.BTSG' >/proc/acpi/call
	check=$(cat /proc/acpi/call | cut -d '' -f1)

	case $check in

	"0x0")
		echo "Battery Conservation Off"
		;;

	"0x1")
		echo "Battery Conservation On"
		;;

	*)
		error 5
		;;
	esac
}

# ----------------------------------------------------------------

check_sudo
setup

# check if an operation is specified
if [ -z "$1" ]; then
	error 8
fi

while [[ "$#" -gt 0 ]]; do
	case $1 in
	-s | --set)
		# set operation

		# check if there is a parameter
		if [ ! -z "$2" ]; then
			# if it's not numeric calls error
			if ! [[ $2 =~ ^[0-9]+$ ]]; then
				error 0
			fi

			# if the parameter is good, set param
			if (($2 >= 0 && $2 <= 3)); then
				set_operation $2

			# if it's not in the expected range calls error
			else
				error 0
			fi
			shift

		# if there is no parameter calls error
		else
			error 0
		fi
		shift
		;;

	-r | --read)
		# read mode
		read_operation
		shift
		;;

	-sc | --set-charge)
		# set charge operation

		# check if there is a parameter
		if [ ! -z "$2" ]; then
			# if it's not numeric calls error
			if ! [[ $2 =~ ^[0-9]+$ ]]; then
				error 1
			fi

			# if the parameter is good, set param
			if (($2 >= 0 && $2 <= 4)); then
				set_charge_operation $2

			# if it's not in the expected range calls error
			else
				error 1
			fi
			shift

		# if there is no parameter calls error
		else
			error 1
		fi
		shift
		;;

	-rc | --read-charge)
		# read charge mode
		read_charge_operation
		shift
		;;

	*)
		error 7
		;;
	esac

done
exit 0
