/proc/slot_to_string(slot)
	switch(slot)
		if(SLOT_BACK)
			return "Backpack"
		if(SLOT_WEAR_MASK)
			return "Mask"
		if(SLOT_HANDS)
			return "Hands"
		if(SLOT_BELT)
			return "Belt"
		if(SLOT_EARS)
			return "Ears"
		if(SLOT_GLASSES)
			return "Glasses"
		if(SLOT_GLOVES)
			return "Gloves"
		if(SLOT_NECK)
			return "Neck"
		if(SLOT_HEAD)
			return "Head"
		if(SLOT_SHOES)
			return "Shoes"
		if(SLOT_WEAR_SUIT)
			return "Suit"
		if(SLOT_W_UNIFORM)
			return "Uniform"
		if(SLOT_IN_BACKPACK)
			return "In backpack"

/proc/random_unique_arachnid_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(pick(GLOB.arachnid_first)) + " " + capitalize(pick(GLOB.arachnid_last))

		if(!findname(.))
			break

