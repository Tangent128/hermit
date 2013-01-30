#!/bin/sh

DIR=~/.hermit

###
## Setup
#

# for now, clone git@github.com:Tangent128/hermit.git into ~/.hermit/
#mkdir -p $DIR

###
## Context Variables & Constants
#

PATCH_FILE=
MODE=

# set by each checkShell invocation:
SHELL_NAME=
RC_FILE=
RC_BASE=

# set by each forPatches iteration:
PATCH=
PATCH_TYPE=
PATCH_NAME=

###
## Action functions
#

metadata() {
	awk -f $DIR/hermitUnpack.awk mode=metadata $PATCH_FILE
}
readPatch() {
	# readPatch index
	awk -f $DIR/hermitUnpack.awk mode=patch patchNum=$1 $PATCH_FILE
}

checkShell() {
	# checkShell shellName
	RC_FILE=
	SHELL_NAME=$1
	
	case $SHELL_NAME in
		sh)
			if test "$ENV"; then
				RC_FILE="$ENV"
			fi
		;;
		zsh)
			RC_FILE=~/.zshrc
		;;
		bash)
			RC_FILE=~/.bashrc
		;;
	esac
	
	if test -f "$RC_FILE"; then
		RC_BASE=$DIR/$(basename $RC_FILE)
		return 0
	else
		return 1
	fi
}

forShells() {
	# forShells shellName command args...
	# used to apply changes to compatable "in-use" shells,
	# will invoke: command specificShellName args...
	compatShell=$1
	theCommand=$2
	shift 2
	
	if [ $compatShell = "sh" ]; then
		checkShell sh && $theCommand $*
		checkShell zsh && $theCommand $*
		checkShell bash && $theCommand $*
		return
	fi
	
	checkShell $compatShell && $theCommand $*
}

# make backup & working copies of a shell's RC file
doBackup() {
	if [ ! "$RC_FILE" -ot "$RC_BASE.old" ]; then
		# copy if needed
		cp "$RC_FILE" "$RC_BASE.old"
		cp "$RC_FILE" "$RC_BASE.new"
	fi
}

# install the patched versions of a shell's RC file
doInstall() {
	if [ "$RC_FILE" -ot "$RC_BASE.new" ]; then
		# copy if needed
		cp "$RC_BASE.new" "$RC_FILE"
	fi
}

forShellFiles() {
	# metadata | forShellFiles command args
	while read type shell etc; do
		if [ "$type" = "shell" ]; then
			forShells $shell $1 $*
		fi
	done
}

forPatches() {
	# metadata | forPatches command args
	theCommand=$1
	shift 1
	while read type shell index patchtype name etc; do
		if [ "$type" = "patch" ]; then
			PATCH=$(readPatch $index)
			PATCH_TYPE=$patchtype
			PATCH_NAME=$name
			forShells $shell $theCommand $*
		fi
	done
}

# WIP
patchFile() {
	# patchFile filebase
	removing="0"
	test "$MODE" = "uninstallPatch" && removing="1"
	
	test $1.new && mv $1.new $1.working
	awk -f $DIR/hermitManage.awk "patchType=$PATCH_TYPE" "patchName=$PATCH_NAME" \
	       "patchText=$PATCH" "removePatch=$removing" $1.working > $1.new
	#echo patched $1
}

###
## Main logic
#

usage() {
	echo "Usage: install patch: $0 -S patchName"
	echo "       uninstall patch: $0 -D patchName"
}
usageErr() {
	echo $*
	usage
	exit 1
}

# determine mode
FLAG=$1

case $FLAG in
	-S*) MODE=installPatch ;;
	-D*) MODE=uninstallPatch ;;
esac

case $FLAG in *y*) : tbd ; ;; esac

test "$MODE" || usageErr No mode given.

# identify patch file
test "$2" || usageErr No patch name given.
PATCH_FILE=$DIR/patches/$2
test -f $PATCH_FILE || usageErr Could not find specified patch.

# apply actions
metadata | forShellFiles doBackup
metadata | forPatches eval patchFile \$RC_BASE 
metadata | forShellFiles doInstall


