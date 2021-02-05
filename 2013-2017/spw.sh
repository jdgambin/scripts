#!/bin/sh

# Installed packages list.
ilog=/home/jdg/.ipkgs

# Uninstalled packages list.
ulog=/home/jdg/.upkgs

# Synopsis: show usage of this script.
usage() {
	printf "Usage: spw [-h|-i pkg...|-u pkg...]\\n" >&2
}

# Synopsis: show help message.
helpmsg() {
	usage
	printf "\\nInstall/uninstall packages with the pacman package\\n"
	printf "manager and keep their names in specific files.\\n"
	printf "\\nConfigure logfiles in the source code of this script.\\n"
	printf "\\nOptions:\\n\\n"
	printf "  -h                       Show this help message and exit.\\n"
	printf "  -i pkg1 pkg2 ... pkgN    Install N packages.\\n"
	printf "  -u pkg1 pkg2 ... pkgN    Uninstall N packages.\\n"
}

# Synopsis: check for wrongly defined or non-existent logfiles.
checklogfiles() {
	if [ -z "$ilog" ] || [ -z "$ulog" ]
	then
		printf "spw: error: there is at least one undefined logfile.\\n" >&2
		exit 1
	fi

	if [ ! -e "$ilog" ] || [ ! -e "$ulog" ]
	then
		printf "spw: error: at least one logfile doesn't exist.\\n" >&2
		exit 1
	fi

	if [ "$ilog" = "$ulog" ]
	then
		printf "spw: error: logfiles are equal.\\n" >&2
		exit 1
	fi
}

# Synopsis: look for irregularities in package names.
checkpkgnames() {
	for pkgname in "$@"
	do
		case "$pkgname" in
		-*)
			printf "spw: error: package names can't start with '-'.\\n" >&2
			exit 1
			;;
		esac
	done
}

# Synopsis: write package name in logfile.
# Parameters:
#	$1:         logfile.
#	$2 ... $n:  package names.
logp() {
	logfile="$1"
	shift 1

	for pkgname in "$@"; do

		if ! grep -q "$pkgname" "$logfile"
		then
			printf "%b\\n" "$pkgname" >> "$logfile"
		fi
	done
}

# Synopsis: remove package name from logfile.
# Parameters:
#	$1:        logfile.
#	$2 ... $n: package names.
unlogp() {
	logfile="$1"
	shift 1

	for pkgname in "$@"; do
		sed -i "/^$pkgname$/d" "$logfile"
	done

	sed -i '/^$/d' "$logfile"
}

# Synopsis: install packages and log their names.
# Parameters:
#	$1 ... $n: package names.
installp() {
	if pacman -S "$@"
	then
		logp "$ilog" "$@"
		unlogp "$ulog" "$@"
	fi
}

# Synopsis: uninstall packages and log their names.
# Parameters:
#	$1 ... $n: package names.
uninstallp() {
	if pacman -Rs "$@"
	then
		logp "$ulog" "$@"
		unlogp "$ilog" "$@"
	fi
}

# Synopsis: check root user.
checksu() {
	if [ "$(id -u)" != "0" ]; then
		printf "spw: error: you're not the root user.\\n" >&2
		exit 1
	fi
}

checklogfiles

while getopts ":hiu" opt
do
	case $opt in
	h)
		helpmsg
		exit
		;;
	i)
		todo=i
		break
		;;
	u)
		todo=u
		break
		;;
	\?)
		printf "spw: error: unknown option '-%b'.\\n" "$OPTARG" >&2
		exit 1
		;;
	esac
done

# There were no arguments passed to the script.
if [ $OPTIND -eq 1 ]; then
	usage
	exit
fi

# Remove -i/-u flag from the argument list,
# everything else is treated as a package name.
shift $((OPTIND - 1))

checksu

if [ "$#" -eq 0 ]; then
	printf "spw: error: no packages selected.\\n" >&2
	exit 1
fi

checkpkgnames "$@"

case "$todo" in
"i")
	installp "$@"
	;;
"u")
	uninstallp "$@"
	;;
*) # This shouldn't be possible.
	exit 1
	;;
esac

exit