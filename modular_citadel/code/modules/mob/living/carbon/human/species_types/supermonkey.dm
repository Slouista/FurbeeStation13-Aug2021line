#define LANGUAGE_MONKEYHAT    	"monkeyhat"
#define ismonkeyman(A) (is_species(A, /datum/species/monkeyman))

/mob/living/carbon/human/species/monkeyman
	race = /datum/species/monkeyman

/datum/species/monkeyman
	name = "Simian"
	id = "monkeyman"
	//limbs_id = "monkeyman"
	icon_limbs = 'modular_citadel/icons/mob/monkeyman_parts.dmi'
	say_mod = "chimpers"

	//mutant_bodyparts = list("tail_human")
	default_features = list("mcolor" = "FFF", /*"tail_human" = "Cat", */"wings" = "None")
	inherent_traits = list(TRAIT_MONKEYLIKE) //currently, this is not enough of a downside for any huge buffs. isadvancedtooluser() is oldcode and not used in modern shit, and monkeys will only get cool shit when that is brought to date
	species_traits = list(NOEYESPRITES) //monkeys have beady little black eyes, and nothing else

	mutant_organs = list(/obj/item/organ/vocal_cords/monkey, /obj/item/organ/tail/monkey)
	//mutanttail = /obj/item/organ/tail/cat
	species_language_holder = /datum/language_holder/monkey
	outfit_important_for_life = /datum/outfit/monkeyhat
	disliked_food = GRAIN | DAIRY | JUNKFOOD //reject modernity
	liked_food = VEGETABLES | MEAT | RAW | FRUIT //embrace tradition
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/outfit/monkeyhat
	name = "Monkey Translator"
	head = /obj/item/clothing/head/helmet/monkeytranslator

/datum/species/monkeyman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/monkeyhat/O = new /datum/outfit/monkeyhat
	switch(current_job) //we have this as a switch for easy futureproofing if someone comes up with stuff like a neck-slot translator for heads
		if("Debtor")
			return 0
	H.equipOutfit(O, visualsOnly)
	return 0

/obj/item/clothing/head/helmet/monkeytranslator
	name = "\improper Uplift-O-Matic V1"
	desc = "A complex array of machinery designed to boost the intelligence of monkeys. Nanotrasen is not responsible for misuse of this device. "
	icon_state = "monkeyhat"
	item_state = "monkeyhat"
	icon = 'modular_citadel/icons/mob/monkeyman_parts1.dmi'
	alternate_worn_icon = 'modular_citadel/icons/mob/monkeyman_parts.dmi'

/obj/item/clothing/head/helmet/monkeytranslator/equipped(mob/user, slot)
	..()
	if(slot == SLOT_HEAD)
		if(ismonkey(user) || ismonkeyman(user))
			to_chat(user, "<span class ='big bold resonate'>As the electrodes on [src] touch your scalp, intelligence and civility enters your brain, and you embrace modern society.</span>")
			user.grant_language(/datum/language/common, TRUE, TRUE, LANGUAGE_MONKEYHAT)
			user.language_holder.selected_language = /datum/language/common
			to_chat(user, "<span class ='notice'>You can now use advanced machinery!</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/datum/species/S = H.dna.species
				S.say_mod = "articulates"

/obj/item/clothing/head/helmet/monkeytranslator/dropped(mob/user)
	..()
	if(ismonkey(user) || ismonkeyman(user))
		to_chat(user, "<span class ='big bold monkeylead'>As the electrodes on [src] stop touching your scalp, you feel your mind slipping... returning to monkey.</span>")
		user.remove_language(/datum/language/common, TRUE, TRUE, LANGUAGE_MONKEYHAT)
		to_chat(user, "<span class ='warning'>You can no longer use advanced machinery!</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/species/S = H.dna.species
			S.say_mod = initial(S.say_mod)

/mob/living/carbon/human/IsAdvancedToolUser()
	if(HAS_TRAIT(src, TRAIT_MONKEYLIKE))
		if(istype(get_item_by_slot(SLOT_HEAD), /obj/item/clothing/head/helmet/monkeytranslator)) //or if they have an uplifter device
			return TRUE
		return FALSE
	return TRUE//Humans can use guns and such

/mob/living/carbon/human/can_use_guns(obj/item/G)
	. = ..()

	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(src.dna.check_mutation(HULK))
			to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return FALSE
		if(HAS_TRAIT(src, TRAIT_NOGUNS))
			to_chat(src, "<span class='warning'>Your fingers don't fit in the trigger guard!</span>")
			return FALSE
	if(mind)
		if(mind.martial_art && mind.martial_art.no_guns) //great dishonor to famiry
			to_chat(src, "<span class='warning'>Use of ranged weaponry would bring dishonor to the clan.</span>")
			return FALSE
	if(HAS_TRAIT(src, TRAIT_MONKEYLIKE))
		return TRUE

	return .

/obj/item/organ/vocal_cords/monkey
	name = "monkey throat"
	desc = "A monkey's overdeveloped vocal chords."
	actions_types = list(/datum/action/item_action/organ_action/use/monkey_vocal_cords)
	spans = list("monkeylead", "yell", "big")
	icon_state = "lungs"

/datum/action/item_action/organ_action/use/monkey_vocal_cords/Trigger()
	if(!IsAvailable())
		return
	if(istype(owner.get_item_by_slot(SLOT_HEAD), /obj/item/clothing/head/helmet/monkeytranslator))
		to_chat(owner, "<span class ='resonate'>You're far too civilized to howl like an ape!</span>")
		return
	var/message = input(owner, "Howl to assert your dominance.", "Howl")
	if(QDELETED(src) || QDELETED(owner) || !message)
		return
	owner.say(".x[message]")

/obj/item/organ/vocal_cords/monkey/handle_speech(message)
	.=..()
	playsound(get_turf(owner), 'sound/creatures/gorilla.ogg', 50) //OOGA BOOGA

/datum/sprite_accessory/tails/human/monkey
	name = "Monkey"
	icon_state = "monkey"
	color_src = null
	icon = 'modular_citadel/icons/mob/monkeyman_parts.dmi'

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A severed monkey tail. Return this to a monkey."
	tail_type = "Monkey"  //!!! WHY DOSE CAT WORK, WHY DOSE ONLY Cat and Clockwork WORK!!!
	icon_state = "monkeytail"

/obj/item/organ/tail/monkey/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(("tail_human" in H.dna.species.mutant_bodyparts))
			H.dna.features["tail_human"] = "None"
			H.dna.species.mutant_bodyparts -= "tail_human"
		H.dna.species.mutant_bodyparts |= "tail_human"
		H.dna.features["tail_human"] = tail_type
		H.update_body()

/obj/item/organ/tail/monkey/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["tail_human"] = "None"
		H.dna.species.mutant_bodyparts -= "tail_human"
		H.update_body()
