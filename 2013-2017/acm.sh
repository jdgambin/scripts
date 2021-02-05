#!/bin/sh

usage() {
	printf "Usage: acm [-h] [-l label] config command [def_arg...]\n"
}

help_msg() {
	usage
cat<<description

 Execute a system command with a series of pre-specified arguments.

 Options:
    -h                  Show this help.
    -l label            String to mark the beginning of arguments in the
                        configuration file, the default value is "args:".

 Operands:
    config              User's configuration file.
    command             System command.
    def_arg             Argument which is always provided to the system command
                        regardless of the configuration file.
description
}

# expand_variable: replace a varibale invocation by its corresponding value.
# Parameters:
#	$1: string of arguments.
expand_variable()
{
	ln=0
	while read -r line; do
		ln=$((ln + 1))

		printf "%s" "$line" | grep -q '^#.*'

		is_comment=$?

		if [ -z "$line" ] || [ $is_comment -eq 0 ]; then
			continue
		elif [ "$line" = "args:" ]; then
			return
		fi

		printf "%s" "$line" | grep -q "="
		verr1=$?

		identifier="$(printf "%s" "$line" | sed 's|=.*$||g')"

		printf "%s" "$identifier" | grep -q '[^[:alnum:]]'
		verr2=$?

		if [ $verr1 -eq 1 ] || [ $verr2 -eq 0 ]; then
			printf "acm: error: incorrect variable definition in line %s.\n" "$ln">&2
			exit 1
		fi

		value="$(printf "%s" "$line" | sed 's|^[^=]*=||g')"

		# Escape special characters.
		value="$(printf "%s" "$value" | sed 's|\\|\\\\|g')"
		value="$(printf "%s" "$value" | sed 's|\x27|\\\x27|g')"
		value="$(printf "%s" "$value" | sed 's|&|\\&|g')"
		value="$(printf "%s" "$value" | sed 's|\||\\\||g')"

		args="$(printf "%s" "$args" | sed "s|\$${identifier}|$value|g")"
	done < "$config_file"
}

# parse_conf_line: parse a line of the configuration file.
# Parameters:
#	$1: line of the configuration file.
# Important variables:
#	$args: arguments ready to be passed to $cmd.
parse_conf_line()
{
	if [ $args_found -eq 2 ]; then
		args_found=1
	fi

	# Delete comments.
	args="$(printf "%s" "$1" | sed 's|#.*||g')"

	if [ $args_found -eq 1 ]; then
		expand_variable "$args"
	elif [ "$args" = "args:" ]; then
		args_found=2
	fi
}

# execute_cmds: run commands based in the configuration file.
# Parameters:
#	$1: configuration file.
execute_cmds() {
	while read -r line; do
		# Skip white lines
		if [ -z "$line" ]; then
			continue
		fi

		parse_conf_line "$line"

		args_nonblank_chars="$(printf "%s" "$args" | tr -d '[:space:]')"

		if [ -n "$args_nonblank_chars" ] && [ $args_found -eq 1 ]; then
			# $def_args are desired arguments for $cmd given as operands of acm
			# and $args are arguments read from $config_file.
			"$cmd" $def_args $args
		fi
	done < "$config_file"
}

# Enable word-splitting if the script is executed with Zsh.
if [ -n "$ZSH_VERSION" ]; then
	setopt sh_word_split
fi

while getopts ":h" opt; do
	case $opt in
	h)
		help_msg
		exit 0
	;;
	\?)
		printf "acm: error: unknown option -%b.\n" "$OPTARG" >&2
		exit 1
	;;
	esac
done

[ -n "$1" ] && config_file="$1"
[ -n "$2" ] && cmd="$2"

if [ -z "$cmd" ] || [ -z "$config_file" ]; then
	usage
	exit 1
fi

if [ $# -gt 2 ]; then
	def_args="$3"

	shift 3

	for arg in "$@"; do
		def_args="$def_args $arg"
	done
fi

if [ ! -f "$config_file" ]; then
	printf "acm: error: '%b' doesn't exist or is not a regular file.\n" "$config_file" >&2
	exit 1
fi

if ! hash "$cmd" 2> /dev/null; then
	printf "acm: error: '%b' is not a command name.\n" "$cmd" >&2
	exit 1
fi

args_found=0

execute_cmds

if [ $args_found -eq 0 ]; then
	printf "acm: error: couldn't find the 'args:' label in the configuration file.\n" >&2
	exit 1
fi
