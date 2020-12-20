GLOBAL_LIST_INIT(arachnid_first, world.file2list("strings/names/arachnid_first.txt"))
GLOBAL_LIST_INIT(arachnid_last, world.file2list("strings/names/arachnid_last.txt"))

/proc/arachnid_name()
	return "[pick(GLOB.arachnid_first)] [pick(GLOB.arachnid_last)]"
