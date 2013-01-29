BEGIN {
	# default parameters
	
	# what to report
	mode="metadata"
	
	# metadata format: lines of following forms:
	#	"patch" indexNum type name shell
	#	"file" shell filename
	#	"shell" shell
	
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
	# knownShells[] exists
}

# state tracking

$1 == "#PATCH" {currentPatch++; knownShells[currentShell] = currentShell}
$1 == "#SHELL" {currentShell = $2}

# actions

mode==Metadata && $1 == "#PATCH" {
	print "patch", currentShell, currentPatch, $2, $3
	next
}
mode==Metadata && $1 == "#FILE" {
	print "file", currentShell, $2
	next
}

mode==Patch && $1 in Directives {next}
mode==Patch && currentPatch == patchNum {gsub(/\\/, "\\\\"); print}

END {
	if(mode==Metadata) {
		for(shell in knownShells) {
			print "shell", shell
		}
	}
}
