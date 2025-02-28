/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags

	var/cooldown = 0
	var/list/protected_species = list()

/datum/component/caltrop/Initialize(_min_damage = 0, _max_damage = 0, _probability = 100,  _flags = NONE, _protected_species = list())
	min_damage = _min_damage
	max_damage = max(_min_damage, _max_damage)
	probability = _probability
	flags = _flags
	protected_species = _protected_species

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), PROC_REF(Crossed))

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent
	if(!A.has_gravity(A.loc))
		return

	if(!prob(probability))
		return

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(PIERCEIMMUNE in H.dna.species.species_traits)
			return

		if(H.dna.species.name in protected_species)
			return

		if(!(flags & CALTROP_BYPASS_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		var/picked_def_zone = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
		var/obj/item/organ/external/O = H.get_organ(picked_def_zone)
		if(!istype(O))
			return
		if(!(flags & CALTROP_BYPASS_ROBOTIC_FOOTS) && (O.is_robotic()))
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		if(H.buckled || (H.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
			return

		var/damage = rand(min_damage, max_damage)

		H.apply_damage(damage, BRUTE, picked_def_zone)

		if(cooldown < world.time - 10) //cooldown to avoid message spam.
			if(!H.incapacitated(ignore_restraints = TRUE))
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", "<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", "<span class='userdanger'>You slide on [A]!</span>")

			cooldown = world.time
		H.Weaken(6 SECONDS)
