/datum/martial_art/cqc
	name = "CQC"
	weight = 7
	block_chance = 75
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/cqc/slam, /datum/martial_combo/cqc/kick, /datum/martial_combo/cqc/restrain, /datum/martial_combo/cqc/pressure, /datum/martial_combo/cqc/consecutive)
	var/restraining = FALSE //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/static/list/areas_under_siege = typecacheof(list(/area/crew_quarters/kitchen,
														/area/crew_quarters/cafeteria,
														/area/crew_quarters/bar,
														/area/syndicate/unpowered/syndicate_space_base/bar,
														/area/syndicate/unpowered/syndicate_space_base/kitchen
														))

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	weight = 5

/datum/martial_art/cqc/under_siege/teach(mob/living/carbon/human/H, make_temporary)
	RegisterSignal(H, COMSIG_ATOM_ENTERED_AREA, PROC_REF(kitchen_check))
	return ..()

/datum/martial_art/cqc/under_siege/remove(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_ATOM_ENTERED_AREA)
	return ..()

/datum/martial_art/cqc/under_siege/proc/kitchen_check(mob/living/carbon/human/H, area/entered_area)
	SIGNAL_HANDLER //COMSIG_ATOM_ENTERED_AREA
	if(!is_type_in_typecache(entered_area, areas_under_siege))
		weight = 0
	else
		weight = initial(weight)

/datum/martial_art/cqc/under_siege/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(!(is_type_in_typecache(A, areas_under_siege)))
		return FALSE
	return ..()

/datum/martial_art/cqc/teach(mob/living/carbon/human/H, make_temporary)
	if(H.mind)
		for(var/datum/martial_art/cqc/under_siege/chef_art in H.mind.known_martial_arts)
			chef_art.remove(H)
	return ..()

/datum/martial_art/cqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)

	return TRUE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "neck chopped", "gut punched", "Big Bossed")
	var/bonus_damage = 13
	if(D.IsWeakened() || D.resting || D.lying_angle)
		bonus_damage += 5
		picked_hit_type = "stomps on"

	D.apply_damage(bonus_damage, BRUTE)
	objective_damage(A, D, bonus_damage, BRUTE)

	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(A.resting && !D.stat && !D.IsWeakened())
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		objective_damage(A, D, 10, BRUTE)
		D.Weaken(2 SECONDS)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = A.get_inactive_hand()
	if(restraining && istype(G) && G.affecting == D)
		D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
							"<span class='userdanger'>[A] puts you into a chokehold!</span>")
		D.SetSleeping(20 SECONDS)
		restraining = FALSE
		if(G.state < GRAB_NECK)
			G.state = GRAB_NECK
		return TRUE
	else
		restraining = FALSE

	var/obj/item/I = null

	if(prob(50))
		if(!D.stat || !D.IsWeakened() || !restraining)
			I = D.get_active_hand()
			D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
								"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.drop_from_active_hand())
				A.put_in_hands(I, ignore_anim = FALSE)
			D.Jitter(4 SECONDS)
			D.apply_damage(5, BRUTE)
			objective_damage(A, D, 5, BRUTE)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", "<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/explaination_header(user)
	to_chat(user, "<b><i>You try to remember some of the basics of CQC.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")
