BEGIN {
	# default parameters
	
	# what to report
	mode="metadata"
	
	# metadata format: lines of either form:
	#	"patch" indexNum shell
	#	"file" shell filename
	
	# index of patch to extract
	patchNum=0
}
BEGIN {
	# Constants
	Directives["#PATCH"] = 1
	Directives["#FILE"] = 1
	Directives["#SHELL"] = 1
	Directives["#PROFRC"] = 1
	
	# reports:
	Metadata="metadata" # metadata
	Patch="patch" # actual patch content
	
	# State
	currentPatch = 0
	currentShell = "sh"
}

# state tracking

$1 == "#PATCH" {currentPatch++}
$1 == "#SHELL" {currentShell = $2}

# actions

mode==Metadata && $1 == "#PATCH" {
	print "patch", currentPatch, currentShell
	next
}
mode==Metadata && $1 == "#FILE" {
	print "file", currentShell, $2
	next
}

mode==Patch && $1 in Directives {next}
mode==Patch && currentPatch == patchNum 

