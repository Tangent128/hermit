BEGIN {
	# default parameters
	
	# what to report (see constants)
	extract="metadata"
}
BEGIN {
	# Constants
	
	# reports:
	Metadata="metadata" # lines of form: indexNum shell
	Files="files" # list of files needed to be placed in ~/.hermit
	Patch="patch" # actual patch content
}
# ...
