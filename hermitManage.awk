BEGIN {
	# defaults for parameters
	patchType = "-"
	patchName = ""
	patchText = "# no content"
	
	# set to remove a patch instead of adding/replacing it
	removePatch = 0
	# set to REMOVE THE ENTIRE HERMIT SECTION of the file
	removeAll = 0
}
BEGIN {
	SectionCode = "#126e8616_Hermit"
	PatchCode = "#PATCH"

	PreSection = 0
	InSection = 1
	SkipOld = 2
	RemoveSection = 3
	PostSection = 4
	
	mode = PreSection
}

function patch() {
	if(!removePatch) {
		print PatchCode, patchType, patchName
		print patchText
	}
}

# speed to end if done
mode == PostSection {print $0; next;}

# remove Hermit section from file if option set
removeAll && $1 == SectionCode && $2 == "BEGIN" {mode = RemoveSection;}
removeAll && $1 == SectionCode && $2 == "END" {mode = PostSection; next;}
mode == RemoveSection {next;}

# start Hermit section
$1 == SectionCode && $2 == "BEGIN" {print $0; mode = InSection; next;}

# check existing patches to see if we need to remove any
(mode == InSection || mode == SkipOld) && $1 == PatchCode {
	if($2 == patchType && $3 == patchName) {
		mode = SkipOld
	} else {
		mode = InSection
	}
}

# done processing section, append patch and speed on to end
$1 == SectionCode && $2 == "END" {patch(); print $0; mode = PostSection; next;}

# skip a patch this one replaces (same type & name)
mode == SkipOld {next;}

# print unskipped lines
{print $0}

# add section if none existed
END {
	if(mode != PostSection) {
		print SectionCode, "BEGIN Hermit-managed section"
		patch()
		print SectionCode, "END Hermit-managed section"
		print
	}
}
