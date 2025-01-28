/mob/living/carbon/human/necromorph/infector
	maxHealth = 90
	class = /datum/necro_class/infector
	necro_species = /datum/species/necromorph/infector

/mob/living/carbon/human/necromorph/infector/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.infector_sounds[audio_type]), volume, vary, extra_range)

/datum/necro_class/infector
	display_name = "Infector"
	desc = "A high value, fragile support, the Infector works as a builder and healer"
	ui_icon = 'deadspace/icons/necromorphs/infector.dmi'
	necromorph_type_path = /mob/living/carbon/human/necromorph/infector
	melee_damage_lower = 10
	melee_damage_upper = 16
	actions = list(
		/datum/action/innate/sense,
	)
	minimap_icon = "infector"

/datum/species/necromorph/infector
	name = "Infector"
	id = SPECIES_NECROMORPH_INFECTOR
	speedmod = 2.1
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/necromorph/infector,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/necromorph/infector,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/infector,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/necromorph/infector,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/necromorph/infector,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/infector,
	)

/datum/species/necromorph/infector/get_scream_sound(mob/living/carbon/human/necromorph/infector)
	return pick(
		'deadspace/sound/effects/creatures/necromorph/infector/infector_shout_long_1.ogg',
		'deadspace/sound/effects/creatures/necromorph/infector/infector_shout_long_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/infector/infector_shout_long_3.ogg',
	)
