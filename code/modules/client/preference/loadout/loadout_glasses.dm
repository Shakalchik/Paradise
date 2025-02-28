/datum/gear/glasses
	subtype_path = /datum/gear/glasses
	slot = SLOT_HUD_GLASSES
	sort_category = "Glasses"

/datum/gear/glasses/sunglasses
	display_name = "cheap sunglasses"
	path = /obj/item/clothing/glasses/sunglasses_fake

/datum/gear/glasses/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/glasses/hipster
	display_name = "Hipster glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/glasses/monocle
	display_name = "Monocle"
	path = /obj/item/clothing/glasses/monocle

/datum/gear/glasses/prescription
	display_name = "Prescription glasses"
	path = /obj/item/clothing/glasses/regular

/datum/gear/glasses/sectacticool
	display_name = "Security tactical glasses"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tacticool
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)
