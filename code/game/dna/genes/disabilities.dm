/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name = "DISABILITY"

	// Mutation to give (or 0)
	var/mutation = 0

	// Activation message
	var/activation_message = ""

	// Yay, you're no longer growing 3 arms
	var/deactivation_message = ""


/datum/dna/gene/disability/can_activate(mob/living/mutant, flags)
	return TRUE // Always set!


/datum/dna/gene/disability/activate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.mutations |= mutation
	if(activation_message)
		to_chat(mutant, span_warning("[activation_message]"))
	else
		testing("[name] has no activation message.")


/datum/dna/gene/disability/deactivate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.mutations -= mutation
	if(deactivation_message)
		to_chat(mutant, span_warning("[deactivation_message]"))
	else
		testing("[name] has no deactivation message.")


/datum/dna/gene/disability/hallucinate
	name = "Hallucinate"
	activation_message = "Your mind says 'Hello'."
	deactivation_message = "Sanity returns. Or does it?"
	instability = -GENE_INSTABILITY_MODERATE
	mutation = HALLUCINATE

/datum/dna/gene/disability/hallucinate/New()
	..()
	block = GLOB.hallucinationblock

/datum/dna/gene/disability/hallucinate/OnMobLife(mob/living/carbon/human/H)
	if(prob(1))
		H.AdjustHallucinate(45 SECONDS)
		H.last_hallucinator_log = "Hallucination Gene"

/datum/dna/gene/disability/epilepsy
	name = "Epilepsy"
	activation_message = "You get a headache."
	deactivation_message = "Your headache is gone, at last."
	instability = -GENE_INSTABILITY_MODERATE
	mutation = EPILEPSY

/datum/dna/gene/disability/epilepsy/New()
	..()
	block = GLOB.epilepsyblock

/datum/dna/gene/disability/epilepsy/OnMobLife(mob/living/carbon/human/H)
	if((prob(1) && H.AmountParalyzed() < 2 SECONDS))
		H.visible_message("<span class='danger'>[H] starts having a seizure!</span>","<span class='alert'>You have a seizure!</span>")
		H.Paralyse(20 SECONDS)
		H.Jitter(2000 SECONDS)

/datum/dna/gene/disability/cough
	name = "Coughing"
	activation_message = "You start coughing."
	deactivation_message = "Your throat stops aching."
	instability = -GENE_INSTABILITY_MINOR
	mutation = COUGHING

/datum/dna/gene/disability/cough/New()
	..()
	block = GLOB.coughblock

/datum/dna/gene/disability/cough/OnMobLife(mob/living/carbon/human/H)
	if((prob(5) && H.AmountParalyzed() <= 2 SECONDS))
		H.drop_from_active_hand()
		H.emote("cough")

/datum/dna/gene/disability/clumsy
	name = "Clumsiness"
	activation_message = "You feel lightheaded."
	deactivation_message = "You regain some control of your movements"
	instability = -GENE_INSTABILITY_MINOR
	mutation = CLUMSY

/datum/dna/gene/disability/clumsy/New()
	..()
	block = GLOB.clumsyblock

/datum/dna/gene/disability/tourettes
	name = "Tourettes"
	activation_message = "You twitch."
	deactivation_message = "Your mouth tastes like soap."
	instability = -GENE_INSTABILITY_MODERATE
	mutation = TOURETTES

/datum/dna/gene/disability/tourettes/New()
	..()
	block = GLOB.twitchblock

/datum/dna/gene/disability/tourettes/OnMobLife(mob/living/carbon/human/H)
	if((prob(10) && H.AmountParalyzed() <= 2 SECONDS))
		H.Stun(20 SECONDS)
		switch(rand(1, 3))
			if(1)
				H.emote("twitch")
			if(2 to 3)
				H.say("[prob(50) ? ";" : ""][pick("ГОВНО", "МОЧА", "БЛЯТЬ", "ПИЗДА", "ХУЕСОС", "ВЫБЛЯДОК", "ХУЙ", "ХОС ХУЕСОС", "СУКА", "ПОШЁЛ НАХУЙ", "ХЕРНЯ", "КОКПИТАН", "ДОЛБАЁБ", "ЕБЛЯ", "НАМ ПИЗДА")]")
		var/x_offset_old = H.pixel_x
		var/y_offset_old = H.pixel_y
		var/x_offset = H.pixel_x + rand(-2, 2)
		var/y_offset = H.pixel_y + rand(-1, 1)
		animate(H, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(H, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)

/datum/dna/gene/disability/nervousness
	name = "Nervousness"
	activation_message="You feel nervous."
	deactivation_message ="You feel much calmer."
	mutation = NERVOUS

/datum/dna/gene/disability/nervousness/New()
	..()
	block = GLOB.nervousblock

/datum/dna/gene/disability/nervousness/OnMobLife(mob/living/carbon/human/H)
	if(prob(10))
		H.Stuttering(20 SECONDS)

/datum/dna/gene/disability/blindness
	name = "Blindness"
	activation_message = "You can't seem to see anything."
	deactivation_message = "You can see now, in case you didn't notice..."
	instability = -GENE_INSTABILITY_MAJOR
	mutation = BLINDNESS

/datum/dna/gene/disability/blindness/New()
	..()
	block = GLOB.blindblock


/datum/dna/gene/disability/blindness/activate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_blind_effects()


/datum/dna/gene/disability/blindness/deactivate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_blind_effects()


/datum/dna/gene/disability/colourblindness
	name = "Colourblindness"
	activation_message = "You feel a peculiar prickling in your eyes while your perception of colour changes."
	deactivation_message ="Your eyes tingle unsettlingly, though everything seems to become alot more colourful."
	instability = -GENE_INSTABILITY_MODERATE
	mutation = COLOURBLIND

/datum/dna/gene/disability/colourblindness/New()
	..()
	block = GLOB.colourblindblock


/datum/dna/gene/disability/colourblindness/activate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_client_colour() //Handle the activation of the colourblindness on the mob.
	mutant.update_icons() //Apply eyeshine as needed.


/datum/dna/gene/disability/colourblindness/deactivate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_client_colour() //Handle the deactivation of the colourblindness on the mob.
	mutant.update_icons() //Remove eyeshine as needed.


/datum/dna/gene/disability/deaf
	name = "Deafness"
	activation_message="It's kinda quiet."
	deactivation_message ="You can hear again!"
	instability = -GENE_INSTABILITY_MAJOR
	mutation = DEAF

/datum/dna/gene/disability/deaf/New()
	..()
	block = GLOB.deafblock


/datum/dna/gene/disability/deaf/activate(mob/mutant, connected, flags)
	. = ..()
	ADD_TRAIT(mutant, TRAIT_DEAF, DNA_TRAIT)


/datum/dna/gene/disability/deaf/deactivate(mob/mutant, connected, flags)
	. = ..()
	REMOVE_TRAIT(mutant, TRAIT_DEAF, DNA_TRAIT)


/datum/dna/gene/disability/nearsighted
	name = "Nearsightedness"
	activation_message="Your eyes feel weird..."
	deactivation_message ="You can see clearly now"
	instability = -GENE_INSTABILITY_MODERATE
	mutation = NEARSIGHTED

/datum/dna/gene/disability/nearsighted/New()
	..()
	block = GLOB.glassesblock


/datum/dna/gene/disability/nearsighted/activate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_nearsighted_effects()


/datum/dna/gene/disability/nearsighted/deactivate(mob/living/mutant, connected, flags)
	. = ..()
	mutant.update_nearsighted_effects()


/datum/dna/gene/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_message = "Thomething doethn't feel right."
	deactivation_message = "You now feel able to pronounce consonants."
	mutation = LISP

/datum/dna/gene/disability/lisp/New()
	..()
	block = GLOB.lispblock

/datum/dna/gene/disability/lisp/OnSay(mob/M, message)
	return replacetext(message,"с",pick("щ","ш","ф"))

/datum/dna/gene/disability/comic
	name = "Comic"
	desc = "This will only bring death and destruction."
	activation_message = "<span class='sans'>Uh oh!</span>"
	deactivation_message = "Well thank god that's over with."
	mutation = COMIC

/datum/dna/gene/disability/comic/New()
	..()
	block = GLOB.comicblock

/datum/dna/gene/disability/wingdings
	name = "Alien Voice"
	desc = "Garbles the subject's voice into an incomprehensible speech."
	activation_message = "<span class='wingdings'>Your vocal cords feel alien.</span>"
	deactivation_message = "Your vocal cords no longer feel alien."
	instability = -GENE_INSTABILITY_MINOR
	mutation = WINGDINGS

/datum/dna/gene/disability/wingdings/New()
	..()
	block = GLOB.wingdingsblock

/datum/dna/gene/disability/wingdings/OnSay(mob/M, message)
	var/garbled_message = ""
	var/i = 1
	while(i <= length(message))
		var/char = lowertext(message[i])
		if(char in GLOB.alphabet)
			if(prob(50)) // upper and lowercase chars have different symbols, we encrypt the word and mix them up
				garbled_message += pick(GLOB.alphabet_uppercase)
			else
				garbled_message += pick(GLOB.alphabet)
		else if(char in GLOB.alphabet_cyrillic)
			if(prob(50))
				garbled_message += pick(GLOB.alphabet_uppercase)
			else
				garbled_message += pick(GLOB.alphabet)
			i++ // rus chars coded by 2 bytes, so we need to skip one byte when encrypting them
		else
			garbled_message += message[i]
		i++
	message = garbled_message
	return message


/datum/dna/gene/disability/weak
	name = "Weak"
	desc = "Делает мышцы цели более слабыми."
	activation_message = "Вы чуствуете слабость в своих мышцах."
	deactivation_message = "Похоже, ваши мышцы снова в норме."
	instability = -GENE_INSTABILITY_MODERATE

/datum/dna/gene/disability/weak/New()
	..()
	block = GLOB.weakblock

/datum/dna/gene/disability/weak/can_activate(mob/M, flags)
	if(STRONG in M.mutations)
		return FALSE
	return ..()


/datum/dna/gene/disability/weak/activate(mob/living/mutant, connected, flags)
	. = ..()
	change_strength(mutant, 1)


/datum/dna/gene/disability/weak/deactivate(mob/living/mutant, connected, flags)
	. = ..()
	change_strength(mutant, -1)


/datum/dna/gene/disability/weak/proc/change_strength(mob/living/M, modifier)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(isvulpkanin(H) || isdrask(H) || isunathi(H))
			H.dna.species.punchdamagelow -= (3 * modifier)
			H.dna.species.punchdamagehigh -= (4 * modifier)
			H.dna.species.strength_modifier -= (0.25 * modifier)
			if(isunathi(H))
				var/datum/species/unathi/U = H.dna.species
				U.tail_strength -= (0.25 * modifier)
			return
		if(ishumanbasic(H))
			H.dna.species.punchdamagelow -= (1 * modifier)
			H.dna.species.punchdamagehigh -= (2 * modifier)
			H.dna.species.strength_modifier -= (0.1 * modifier)
		else
			H.dna.species.punchdamagelow -= (2 * modifier)
			H.dna.species.punchdamagehigh -= (3 * modifier)
			H.dna.species.strength_modifier -= (0.15 * modifier)
