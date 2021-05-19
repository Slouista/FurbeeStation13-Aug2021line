/mob/living/carbon/monkey/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bp = def_zone
			if(bp)
				return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/monkey/proc/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, back, gloves, shoes, glasses, ears, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

/mob/living/carbon/monkey/on_hit(obj/item/projectile/P)
	if(dna?.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/monkey/bullet_act(obj/item/projectile/P, def_zone)
	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	if(mind)
		if(mind.martial_art && !incapacitated(FALSE, TRUE) && mind.martial_art.can_use(src) && mind.martial_art.deflection_chance) //Some martial arts users can deflect projectiles!
			if(prob(mind.martial_art.deflection_chance))
				if((mobility_flags & MOBILITY_USE) && dna && !dna.check_mutation(HULK)) //But only if they're otherwise able to use items, and hulks can't do it
					if(!isturf(loc)) //if we're inside something and still got hit
						P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
						loc.bullet_act(P)
						return BULLET_ACT_HIT
					if(mind.martial_art.deflection_chance >= 100) //if they can NEVER be hit, lets clue sec in ;)
						visible_message("<span class='danger'>[src] deflects the projectile; [p_they()] can't be hit with ranged weapons!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
					else
						visible_message("<span class='danger'>[src] deflects the projectile!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
					playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
					if(!mind.martial_art.reroute_deflection)
						return BULLET_ACT_BLOCK
					else
						P.firer = src
						P.setAngle(rand(0, 360))//SHING
						return BULLET_ACT_FORCE_PIERCE

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		if(P.reflectable & REFLECT_NORMAL)
			if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
								"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
				// Find a turf near or on the original location to bounce to
				if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
					P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
					loc.bullet_act(P)
					return BULLET_ACT_HIT
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = curloc
					P.firer = src
					P.yo = new_y - curloc.y
					P.xo = new_x - curloc.x
					var/new_angle_s = P.Angle + rand(120,240)
					while(new_angle_s > 180)	// Translate to regular projectile degrees
						new_angle_s -= 360
					P.setAngle(new_angle_s)

				return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

		if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration))
			P.on_hit(src, 100, def_zone)
			return BULLET_ACT_HIT

	return ..(P, def_zone)

/mob/living/carbon/monkey/proc/check_reflect(def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone, src) == 1)
			return 1
	return 0

/mob/living/carbon/monkey/proc/check_shields(atom/AM, var/damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	for(var/obj/item/I in held_items)
		if(!istype(I, /obj/item/clothing))
			if(I.hit_reaction(src, AM, attack_text, damage, attack_type))
				I.on_block(src, AM, attack_text, damage, attack_type)
				return 1
	if(wear_neck)
		if(wear_neck.hit_reaction(src, AM, attack_text, damage, attack_type))
			return TRUE
	if(head)
		if(head.hit_reaction(src, AM, attack_text, damage, attack_type))
			return TRUE
	return FALSE

/mob/living/carbon/monkey/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
			return TRUE
	return FALSE

/mob/living/carbon/monkey/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	else if(I)
		if(((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedding.embedded_ignore_throwspeed_threshold)
			if(can_embed(I))
				if(prob(I.embedding.embed_chance) && !HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
					throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
					var/obj/item/bodypart/L = pick(bodyparts)
					L.embedded_objects |= I
					I.add_mob_blood(src)//it embedded itself in you, of course it's bloody!
					I.forceMove(src)
					L.receive_damage(I.w_class*I.embedding.embedded_impact_pain_multiplier)
					visible_message("<span class='danger'>[I] embeds itself in [src]'s [L.name]!</span>","<span class='userdanger'>[I] embeds itself in your [L.name]!</span>")
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
					hitpush = FALSE
					skipcatch = TRUE //can't catch the now embedded item

	return ..()

/mob/living/carbon/monkey/grippedby(mob/living/user, instant = FALSE)
	if(head)
		head.add_fingerprint(user)
	..()


/mob/living/carbon/monkey/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return 0

	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target
	else
		affecting = get_bodypart(ran_zone(user.zone_selected))
	var/target_area = parse_zone(check_zone(user.zone_selected)) //our intended target
	if(affecting)
		if(I.force && I.damtype != STAMINA && affecting.status == BODYPART_ROBOTIC) // Bodpart_robotic sparks when hit, but only when it does real damage
			if(I.force >= 5)
				do_sparks(1, FALSE, loc)
				if(prob(25))
					new /obj/effect/decal/cleanable/oil(loc)

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// the attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, a_intent, src)
	// end edit

/mob/living/carbon/monkey/help_shake_act(mob/living/carbon/M)
	if(health < 0 && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.do_cpr(src)
	else
		..()

/mob/living/carbon/monkey/attack_paw(mob/living/M)
	if(..()) //successful monkey bite.
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		if(M.limb_destroyer)
			dismembering_strike(M, affecting.body_zone)
		if(stat != DEAD)
			var/dmg = rand(1, 5)
			apply_damage(dmg, BRUTE, affecting)

/mob/living/carbon/monkey/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M)
	if(..())	//To allow surgery to return properly.
		return

	switch(M.a_intent)
		if("help")
			help_shake_act(M)
		if("grab")
			grabbedby(M)
		if("harm")
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message("<span class='danger'>[M] punches [name]!</span>", \
					"<span class='userdanger'>[M] punches you!</span>", null, COMBAT_MESSAGE_RANGE)
			playsound(loc, "punch", 25, 1, -1)
			var/damage = M.dna.species.punchdamage
			var/obj/item/bodypart/affecting = get_bodypart(check_zone(M.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			apply_damage(damage, BRUTE, affecting)
			log_combat(M, src, "attacked")
		if("disarm")
			if(!IsUnconscious())
				M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
				Knockdown(40)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				log_combat(M, src, "pushed")
				visible_message("<span class='danger'>[M] pushes [src] down!</span>", \
					"<span class='userdanger'>[M] pushes you down!</span>")
				dropItemToGround(get_active_held_item())

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if (M.a_intent == INTENT_HARM)
			if ((prob(95) && health > 0))
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if(AmountUnconscious() < 300)
						Unconscious(rand(200, 300))
					visible_message("<span class='danger'>[M] wounds [name]!</span>", \
							"<span class='userdanger'>[M] wounds you!</span>", null, COMBAT_MESSAGE_RANGE)
				else
					visible_message("<span class='danger'>[M] slashes [name]!</span>", \
							"<span class='userdanger'>[M] slashes you!</span>", null, COMBAT_MESSAGE_RANGE)

				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				log_combat(M, src, "attacked")
				if(!affecting)
					affecting = get_bodypart(BODY_ZONE_CHEST)
				if(!dismembering_strike(M, affecting.body_zone)) //Dismemberment successful
					return 1
				apply_damage(damage, BRUTE, affecting)

			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M]'s lunge misses [name]!</span>", \
						"<span class='userdanger'>[M]'s lunge misses you!</span>", null, COMBAT_MESSAGE_RANGE)

		if (M.a_intent == INTENT_DISARM)
			var/obj/item/I = null
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			if(prob(95))
				Paralyze(20)
				visible_message("<span class='danger'>[M] tackles [name] down!</span>", \
						"<span class='userdanger'>[M] tackles you down!</span>", null, COMBAT_MESSAGE_RANGE)
			else
				I = get_active_held_item()
				if(dropItemToGround(I))
					visible_message("<span class='danger'>[M] disarms [name]!</span>", \
						"<span class='userdanger'>[M] disarms you!</span>", null, COMBAT_MESSAGE_RANGE)
				else
					I = null
			log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			updatehealth()


/mob/living/carbon/monkey/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = M.melee_damage
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, M.melee_damage_type, affecting)

/mob/living/carbon/monkey/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = 20
		if(M.is_adult)
			damage = 30
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/acid_act(acidpwr, acid_volume, bodyzone_hit)
	. = 1
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD)
		if(wear_mask)
			if(!(wear_mask.resistance_flags & UNACIDABLE))
				wear_mask.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, "<span class='warning'>Your mask protects you from the acid.</span>")
			return
		if(head)
			if(!(head.resistance_flags & UNACIDABLE))
				head.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, "<span class='warning'>Your hat protects you from the acid.</span>")
			return
	take_bodypart_damage(acidpwr * min(0.6, acid_volume*0.1))


/mob/living/carbon/monkey/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	switch (severity)
		if (EXPLODE_DEVASTATE)
			gib()
			return

		if (EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			damage_clothes(200, BRUTE, "bomb")
			adjustEarDamage(30, 120)
			Unconscious(200)

		if(EXPLODE_LIGHT)
			take_overall_damage(30, 0)
			damage_clothes(50, BRUTE, "bomb")
			adjustEarDamage(15,60)
			Unconscious(160)


	//attempt to dismember bodyparts
	if(severity <= 2)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break
