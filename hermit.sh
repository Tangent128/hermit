#!/bin/sh

DIR=~/.hermit

###
## Setup
#

# for now, clone git@github.com:Tangent128/hermit.git into ~/.hermit/
#mkdir -p $DIR

###
## Action functions
#

installPatch() {
	REALFILE=$1
	TMPFILE=$DIR/$(basename $1)
	PATCH=$2
	PATCH_TYPE=$3
	PATCH_NAME=$4
	
	cp $REALFILE $TMPFILE.old
	
	awk -f $DIR/hermitManage.awk "patchType=$PATCH_TYPE" "patchName=$PATCH_NAME" \
	       "patchText=$PATCH" $TMPFILE.old > $TMPFILE.new
	
	
	cp $TMPFILE.new $REALFILE
	#echo would add [$PATCH_TYPE $PATCH_NAME] to $REALFILE [tmp $DIR/$FILENAME]
}

###
## Main logic
# 

CharLookup=$DIR/charLookup/charLookup
CMD="char=awk -f $CharLookup.awk $CharLookup.data"
PATCH="alias \"$CMD\""

patchIfExist() {
	test -f $1 && installPatch $1 "$PATCH" tool char
}

patchIfExist ~/.bashrc
patchIfExist ~/.zshrc

