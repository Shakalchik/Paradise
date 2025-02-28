
//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/makeDatumRefLists()
	//markings
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.marking_styles_list)
	//head accessory
	init_sprite_accessory_subtypes(/datum/sprite_accessory/head_accessory, GLOB.head_accessory_styles_list)
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_public_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list, GLOB.hair_styles_full_list)
	//hair gradients
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair_gradient, GLOB.hair_gradients_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list, GLOB.socks_m, GLOB.socks_f)
	//alt heads
	init_sprite_accessory_subtypes(/datum/sprite_accessory/alt_heads, GLOB.alt_heads_list)

	init_subtypes(/datum/surgery_step, GLOB.surgery_steps)
	init_subtypes(/obj/item/slimepotion, GLOB.slime_potions)
	// Different bodies
	__init_body_accessory(/datum/body_accessory/body)
	// Different tails
	__init_body_accessory(/datum/body_accessory/tail)
	// Different wings
	__init_body_accessory(/datum/body_accessory/wing)

	// Setup species:accessory relations
	initialize_body_accessory_by_species()

	for(var/path in (subtypesof(/datum/surgery)))
		GLOB.surgeries_list += new path()

	init_datum_subtypes(/datum/job, GLOB.joblist, list(/datum/job/ai, /datum/job/cyborg), "title")
	init_datum_subtypes(/datum/superheroes, GLOB.all_superheroes, null, "name")
	init_datum_subtypes(/datum/language, GLOB.all_languages, null, "name")

	// Setup languages
	for(var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.all_languages[language_name]
		if(!(language.flags & NONGLOBAL))
			GLOB.language_keys[":[lowertext(language.key)]"] = language
			GLOB.language_keys[".[lowertext(language.key)]"] = language
			GLOB.language_keys["#[lowertext(language.key)]"] = language
			GLOB.language_keys[":[sanitize_english_string_to_russian(language.key)]"] = language
			GLOB.language_keys[".[sanitize_english_string_to_russian(language.key)]"] = language
			GLOB.language_keys["#[sanitize_english_string_to_russian(language.key)]"] = language

	var/rkey = 0
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		S.race_key = ++rkey //Used in mob icon caching.
		GLOB.all_species[S.name] = S

		if(IS_WHITELISTED in S.species_traits)
			GLOB.whitelisted_species += S.name

	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

	//Pipe list building
	init_subtypes(/datum/pipes, GLOB.construction_pipe_list)
	for(var/D in GLOB.construction_pipe_list)
		var/datum/pipes/P = D
		if(P.rpd_dispensable)
			GLOB.rpd_pipe_list += list(list("pipe_name" = P.pipe_name, "pipe_id" = P.pipe_id, "pipe_type" = P.pipe_type, "pipe_category" = P.pipe_category, "orientations" = P.orientations, "pipe_icon" = P.pipe_icon, "bendy" = P.bendy))

	// Setup PAI software
	for(var/type in subtypesof(/datum/pai_software))
		var/datum/pai_software/P = new type()
		if(GLOB.pai_software_by_key[P.id])
			var/datum/pai_software/O = GLOB.pai_software_by_key[P.id]
			to_chat(world, "<span class='warning'>pAI software module [P.name] has the same key as [O.name]!</span>")
			continue
		GLOB.pai_software_by_key[P.id] = P

	// Setup loadout gear
	for(var/geartype in subtypesof(/datum/gear))
		var/datum/gear/G = geartype

		var/use_name = initial(G.display_name)
		var/use_category = initial(G.sort_category)

		if(G == initial(G.subtype_path))
			continue

		if(!use_name)
			error("Loadout - Missing display name: [G]")
			continue
		if(!initial(G.cost))
			error("Loadout - Missing cost: [G]")
			continue
		if(!initial(G.path))
			error("Loadout - Missing path definition: [G]")
			continue

		if(!GLOB.loadout_categories[use_category])
			GLOB.loadout_categories[use_category] = new /datum/loadout_category(use_category)
		var/datum/loadout_category/LC = GLOB.loadout_categories[use_category]
		GLOB.gear_datums[use_name] = new geartype
		LC.gear[use_name] = GLOB.gear_datums[use_name]

	GLOB.loadout_categories = sortAssoc(GLOB.loadout_categories)
	for(var/loadout_category in GLOB.loadout_categories)
		var/datum/loadout_category/LC = GLOB.loadout_categories[loadout_category]
		LC.gear = sortAssoc(LC.gear)


	// Setup a list of robolimbs
	GLOB.basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/R = new limb_type()
		GLOB.all_robolimbs[R.company] = R
		if(!R.unavailable_at_chargen)
			if(R != BODY_ZONE_HEAD && R != BODY_ZONE_CHEST && R != BODY_ZONE_PRECISE_GROIN ) //Part of the method that ensures only IPCs can access head, chest and groin prosthetics.
				if(R.has_subtypes) //Ensures solos get added to the list as well be incorporating has_subtypes == 1 and has_subtypes == 2.
					GLOB.chargen_robolimbs[R.company] = R //List only main brands and solo parts.
		if(R.selectable)
			GLOB.selectable_robolimbs[R.company] = R

	// Setup world topic handlers
	for(var/topic_handler_type in subtypesof(/datum/world_topic_handler))
		var/datum/world_topic_handler/wth = new topic_handler_type()
		if(!wth.topic_key)
			stack_trace("[wth.type] has no topic key!")
			continue
		if(GLOB.world_topic_handlers[wth.topic_key])
			stack_trace("[wth.type] has the same topic key as [GLOB.world_topic_handlers[wth.topic_key]]! ([wth.topic_key])")
			continue
		GLOB.world_topic_handlers[wth.topic_key] = topic_handler_type

	GLOB.emote_list = init_emote_list()
	GLOB.uplink_items = init_uplink_items_list()

	// Keybindings
	for(var/path in subtypesof(/datum/keybinding))
		var/datum/keybinding/D = path
		if(initial(D.name))
			GLOB.keybindings += new path()

	// Init chemical reagents
	init_datum_subtypes(/datum/reagent, GLOB.chemical_reagents_list, null, "id")

	// Chemical Reactions - Initialises all /datum/chemical_reaction into an assoc list of: reagent -> list of chemical reactions
	// For example:
	// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma
	for(var/path in subtypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/reaction_datum = new path()
		if(!length(reaction_datum?.required_reagents))
			continue

		for(var/reagent in reaction_datum.required_reagents)
			if(!GLOB.chemical_reactions_list[reagent])
				GLOB.chemical_reactions_list[reagent] = list()
			GLOB.chemical_reactions_list[reagent] += reaction_datum

	// Init disease archive
	GLOB.archive_diseases += list(
		"sneeze" = new /datum/disease/virus/advance/preset/sneezing(),
		"cough" = new /datum/disease/virus/advance/preset/cough(),
		"voice_change" = new /datum/disease/virus/advance/preset/voice_change(),
		"heal" = new /datum/disease/virus/advance/preset/heal(),
		"hallucigen" = new /datum/disease/virus/advance/preset/hullucigen(),
		"sensory_restoration" = new /datum/disease/virus/advance/preset/sensory_restoration(),
		"mind_restoration" = new /datum/disease/virus/advance/preset/mind_restoration(),
		"damage_converter:heal:viralevolution" = new /datum/disease/virus/advance/preset/advanced_regeneration(),
		"dizzy:flesh_eating:viraladaptation:youth" = new /datum/disease/virus/advance/preset/stealth_necrosis(),
		"beard:itching:voice_change" = new /datum/disease/virus/advance/preset/pre_kingstons(),
		"love" = new /datum/disease/virus/advance/preset/love(),
		"aggression" = new /datum/disease/virus/advance/preset/aggression(),
		"obsession" = new /datum/disease/virus/advance/preset/obsession(),
		"confusion" = new /datum/disease/virus/advance/preset/confusion(),
		"bones" = new /datum/disease/virus/advance/preset/bones(),
		"laugh" = new /datum/disease/virus/advance/preset/laugh(),
		"moan" = new /datum/disease/virus/advance/preset/moan(),
		"infection" = new /datum/disease/virus/advance/preset/infection(),
		"hallucigen:laugh:moan" = new /datum/disease/virus/advance/preset/pre_loyalty()
	)

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))	L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

/proc/init_datum_subtypes(prototype, list/L, list/pexempt, assocvar)
	if(!istype(L))	L = list()
	for(var/path in subtypesof(prototype) - pexempt)
		var/datum/D = new path()
		if(istype(D))
			var/assoc
			if(D.vars["[assocvar]"]) //has the var
				assoc = D.vars["[assocvar]"] //access value of var
			if(assoc) //value gotten
				L["[assoc]"] = D //put in association
	return L


/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			if(!.[E.key])
				.[E.key] = list(E)
			else
				.[E.key] += E
		else if(E.message) //Assuming all non-base emotes have this
			stack_trace("Keyless emote: [E.type]")

		if(E.key_third_person) //This one is optional
			if(!.[E.key_third_person])
				.[E.key_third_person] = list(E)
			else
				.[E.key_third_person] |= E


/proc/init_uplink_items_list()
	. = list()
	for(var/datum/uplink_item/item_path as anything in subtypesof(/datum/uplink_item))
		if(!initial(item_path.item))
			continue
		var/datum/uplink_item/item = new item_path
		. += item


/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()


/proc/update_mob_config_movespeeds()
	for(var/mob/M as anything in GLOB.mob_list)
		M.update_config_movespeed()

