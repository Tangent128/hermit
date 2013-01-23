BEGIN {
	ORS=" ";
	
	if(ARGC <= 2) {
		print "Please specify keywords to look for."
		exit
	}
	
	for(i = 2; i < ARGC; i++) {
		KEYWORDS[i] = tolower(ARGV[i])
		delete ARGV[i]
	}
}

function filter() {
	for(key in KEYWORDS) {
		if($0 !~ KEYWORDS[key]) {
			return 0
		}
	}
	return 1
}

/^#/ {next}

filter() {print $1}

END { printf "\n" }
