// There, now `stat` is a proper state-machine

/mob/living/proc/KnockOut(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("KnockOut called on a dead mob."), src)
		return 0
	else if(stat == UNCONSCIOUS)
		return 0
	add_attack_logs(src, null, "Fallen unconscious", ATKLOG_ALL)
	set_stat(UNCONSCIOUS)
	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
		set_typing_indicator(FALSE)
	return 1

/mob/living/proc/WakeUp(updating = 1)
	if(stat == DEAD)
		log_runtime(EXCEPTION("WakeUp called on a dead mob."), src)
		return 0
	else if(stat == CONSCIOUS)
		return 0
	add_attack_logs(src, null, "Woken up", ATKLOG_ALL)
	set_stat(CONSCIOUS)
	if(updating)
		update_sight()
		update_blind_effects()
		update_canmove()
	return 1

/mob/living/proc/can_be_revived()
	. = TRUE
	// if(health <= min_health)
	if(health <= HEALTH_THRESHOLD_DEAD)
		return FALSE

// death() is used to make a mob die

// handles revival through other means than cloning or adminbus (defib, IPC repair)
/mob/living/proc/update_revive(updating = TRUE, force = FALSE)
	if(stat != DEAD)
		return FALSE
	if(!force && !can_be_revived())
		return FALSE
	add_attack_logs(src, null, "Came back to life", ATKLOG_ALL)
	set_stat(CONSCIOUS)
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list += src
	if(mind)
		GLOB.respawnable_list -= src
	timeofdeath = null
	if(updating)
		update_canmove()
		update_blind_effects()
		update_blurry_effects()
		update_sight()
		updatehealth("update revive")
		hud_used?.reload_fullscreen()

	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, updating)
	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerRevives(src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerRevives(src)

	if(mind)
		for(var/obj/effect/proc_holder/spell/spell as anything in mind.spell_list)
			spell.updateButtonIcon()

	return TRUE

/mob/living/proc/check_death_method()
	return TRUE
