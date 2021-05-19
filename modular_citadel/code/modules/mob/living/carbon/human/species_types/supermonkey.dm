/// Globals
GLOBAL_VAR(monkey_notify_cooldown)

/// code\__DEFINES\language.dm
#define LANGUAGE_MONKEYHAT    	"monkeyhat"

/// code\__DEFINES\is_helpers.dm
#define ismonkeyman(A) (is_species(A, /datum/species/monkeyman))

/// code\modules\mob\living\carbon\human\human.dm
/mob/living/carbon/human/species/monkeyman
	race = /datum/species/monkeyman

///code\modules\mob\living\carbon\human\human_helpers.dm
/mob/living/carbon/human/IsAdvancedToolUser()
	if(HAS_TRAIT(src, TRAIT_MONKEYLIKE))
		if(istype(get_item_by_slot(SLOT_HEAD), /obj/item/clothing/head/helmet/monkeytranslator)) //or if they have an uplifter device
			return TRUE
		return FALSE
	return TRUE//Humans can use guns and such

///code\modules\mob\living\carbon\human\human_helpers.dm & code\modules\mob\living\living.dm
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

/// modular_citadel\code\modules\mob\living\carbon\human\species_types\supermonkey.dm
/datum/species/monkeyman
	name = "Simian"
	id = "monkeyman"
	//limbs_id = "monkeyman" // you only need a limb_id if you wish to identify your race and its body parts seperately IE id = angel, limbs_id = human
	icon_limbs = 'modular_citadel/icons/mob/monkeyman_parts.dmi'
	say_mod = "chimpers"

	default_features = list("mcolor" = "FFF", "wings" = "None")
	inherent_traits = list(TRAIT_MONKEYLIKE) //currently, this is not enough of a downside for any huge buffs. isadvancedtooluser() is oldcode and not used in modern shit, and monkeys will only get cool shit when that is brought to date
	species_traits = list(NOEYESPRITES) //monkeys have beady little black eyes, and nothing else

	mutant_organs = list(/obj/item/organ/vocal_cords/monkey, /obj/item/organ/tail/monkey) // Lets handle this tail as an organ! RIP || mutanttail = /obj/item/organ/tail/cat || //mutant_bodyparts = list("tail_human") || default_features = "tail_human" = "Cat",
	species_language_holder = /datum/language_holder/monkey
	outfit_important_for_life = /datum/outfit/monkeyhat
	disliked_food = GRAIN | DAIRY | JUNKFOOD //reject modernity
	liked_food = VEGETABLES | MEAT | RAW | FRUIT //embrace tradition
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/// Sometimes a race needs new organs this is a speaking organ like a tongue and uses the propertys of vocal_cords but also the fallowing triggered action
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

/// tails can be mutant bodyparts like on most furrys but they can also be coded like organs, this works the same as a felinid tail dose
/datum/sprite_accessory/tails/human/monkey
	name = "Monkey"
	icon_state = "monkey"
	color_src = null
	icon = 'modular_citadel/icons/mob/monkeyman_parts.dmi'

/obj/item/organ/tail/monkey
	name = "monkey tail"
	desc = "A severed monkey tail. Return this to a monkey."
	tail_type = "Monkey"
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

/// sometimes you want to create an object connected to a race, the monkeyhat uses a lot of the same code plasmemes use to get there job specifc suits
/datum/species/monkeyman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/monkeyhat/O = new /datum/outfit/monkeyhat
	switch(current_job) //we have this as a switch for easy futureproofing if someone comes up with stuff like a neck-slot translator for heads ~zeskorion
		if("Debtor")
			return 0
	H.equipOutfit(O, visualsOnly)
	return 0

/datum/outfit/monkeyhat
	name = "Monkey Translator"
	head = /obj/item/clothing/head/helmet/monkeytranslator

//code\modules\research\designs\machine_designs.dm
/datum/design/monkeytranslator
	name = "Uplift-O-Matic"
	desc = "A complex array of machinery designed to boost the intelligence of monkeys. Nanotrasen is not responsible for misuse of this device."
	id = "monkey_translator"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500, /datum/material/copper = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/clothing/head/helmet/monkeytranslator
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

//code\modules\research\techweb\all_nodes.dm
/datum/techweb_node/adv_genetics
	id = "adv_genetics"
	display_name = "Advanced Genetic Engineering"
	description = "Return to Monkey."
	prereq_ids = list("cloning", "neural_programming")
	design_ids = list("monkey_translator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/obj/item/clothing/head/helmet/monkeytranslator
	name = "\improper Uplift-O-Matic"
	desc = "A complex array of machinery designed to boost the intelligence of monkeys. Nanotrasen is not responsible for misuse of this device. "
	icon_state = "monkeyhat"
	item_state = "monkeyhat"
	icon = 'modular_citadel/icons/mob/monkeyman_parts1.dmi' /// icon defines the primary file location for your sprite for an object, the specific sprite is called using icon_state
	alternate_worn_icon = 'modular_citadel/icons/mob/monkeyman_parts.dmi' /// this defines an alternate file location which also uses icon_state for the object but this is only used when rendering it worn on a human mob
	var/mob/living/carbon/human/monkey = null

/obj/item/clothing/head/helmet/monkeytranslator/uphat
	name = "top-hat"
	desc = "It's an amish looking hat with some strange wires."
	icon = 'icons/obj/clothing/hats.dmi'
	alternate_worn_icon = null
	icon_state = "tophat"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1

/obj/item/clothing/head/helmet/monkeytranslator/equipped(mob/user, slot)
	..()
	if(slot == SLOT_HEAD)
		if(ismonkey(user) || ismonkeyman(user))
			to_chat(user, "<span class ='big bold resonate'>As the electrodes on [src] touch your scalp, intelligence and civility enters your brain, and you embrace modern society.</span>")
			user.grant_language(/datum/language/monkey, TRUE, TRUE, LANGUAGE_MONKEYHAT)
			user.grant_language(/datum/language/common, TRUE, TRUE, LANGUAGE_MONKEYHAT)
			to_chat(user, "<span class ='notice'>You can now use advanced machinery!</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/datum/species/S = H.dna.species
				S.say_mod = "articulates"

/obj/item/clothing/head/helmet/monkeytranslator/dropped(mob/user)
	..()
	if(ismonkey(user) || ismonkeyman(user))
		to_chat(user, "<span class ='big bold monkeylead'>As the electrodes on [src] stop touching your scalp, you feel your mind slipping... returning to monkey.</span>")
		user.remove_language(/datum/language/common, FALSE, TRUE, LANGUAGE_MONKEYHAT) // lets retain the ability to understand common although not speak it
		to_chat(user, "<span class ='warning'>You can no longer use advanced machinery!</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/species/S = H.dna.species
			S.say_mod = initial(S.say_mod)

/// Hit reactions are a slave to the process check shields inside human_defense.dm it restricts what item slots can have hit reactions even happen.
/obj/item/clothing/head/helmet/monkeytranslator/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(GLOB.monkey_notify_cooldown <= world.time)
		if( (owner.stat != DEAD) && (!owner.key) && (!owner.mind.ghostname) )
			GLOB.monkey_notify_cooldown = world.time + 600
			monkey = owner
			playsound(get_turf(src.monkey), 'sound/machines/defib_charge.ogg', 300, 1, 5)
			INVOKE_ASYNC(src, .proc/mindtransfer)

/obj/item/clothing/head/helmet/monkeytranslator/proc/mindtransfer()
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [src.monkey]?", ROLE_SENTIENCE, null, null, 100, src.monkey, POLL_IGNORE_SENTIENCE_POTION)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		src.monkey.key = chosen.key
		log_game("[chosen.key] has taken over [src.monkey.name] at [loc].")
		message_admins("[chosen.key] has taken over [src.monkey.name] at [ADMIN_VERBOSEJMP(loc)].")
		playsound(get_turf(src.monkey), 'sound/machines/defib_zap.ogg', 300, 1, 5)
		src.monkey = null
