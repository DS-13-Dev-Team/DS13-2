//It exists just for compability. Don't add any vars or special behaviours
/datum/species/necromorph
	name = "Necromorph"
	id = SPECIES_NECROMORPH
	//There is no way to become it. Period.
	changesource_flags = NONE
	//For blood please go to necro_defines
	sexes = FALSE
	bodytype = BODYTYPE_HUMANOID|BODYTYPE_ORGANIC|BODYTYPE_NECROMORPH

	max_bodypart_count = 6
	burnmod = 1.2

	examine_limb_id = SPECIES_NECROMORPH
	meat = /obj/item/food/meat/slab/human/mutant/necro
	liked_food = NONE
	disliked_food = NONE
	toxic_food = NONE
	//Heat and cold does not traditionally affect necros, but fire can still hurt them
	heat_discomfort_level = INFINITY
	cold_discomfort_level = -(INFINITY)
	///We don't process reagents
	reagent_flags = NONE
	no_equip = list(
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_EYES,
		ITEM_SLOT_EARS,
		ITEM_SLOT_MASK,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_FEET,
		ITEM_SLOT_ID,
		ITEM_SLOT_BELT,
		ITEM_SLOT_BACK,
		ITEM_SLOT_DEX_STORAGE,
		ITEM_SLOT_NECK,
		ITEM_SLOT_BACKPACK,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_LPOCKET,
		ITEM_SLOT_RPOCKET,
		ITEM_SLOT_HANDCUFFED,
		ITEM_SLOT_LEGCUFFED,
	)

	inherent_traits = list(
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_DEFIB_BLACKLISTED,
		TRAIT_BADDNA,
		TRAIT_GENELESS,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOMETABOLISM,
		TRAIT_TOXIMMUNE,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_FEARLESS,
		TRAIT_NO_SOUL,
		TRAIT_CANT_RIDE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHUNGER,
		TRAIT_NO_PAINSHOCK,
		TRAIT_NOEARS,
		TRAIT_FAKEDEATH,
	)

	say_mod = "roars"
	scream_verb = "roars"
	species_language_holder = /datum/language_holder/necro_talk

	species_traits = list(
		NOBLOOD,
		NOTRANSSTING,
		NOZOMBIE,
		NO_UNDERWEAR,
		NO_DNA_COPY,
		AGENDER,
		NOAUGMENTS,
		NOEYESPRITES,
		NOBLOODOVERLAY,
		NOAUGMENTS,
	)

	organs = list(
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
	) //Necros are mostly just biomass, little to no guts

	inherent_biotypes = MOB_ORGANIC|MOB_UNDEAD|MOB_HUMANOID
	inherent_factions = list(FACTION_NECROMORPH)
	species_mob_size = MOB_SIZE_HUMAN
	fire_overlay = "generic_burning"

/datum/species/necromorph/check_roundstart_eligible()
	return FALSE

/datum/species/necromorph/random_name(gender,unique,lastname)
	return "[name] [rand(1, 999)]"

//The natural healing of the necromorph
/datum/species/necromorph/spec_life(mob/living/carbon/N, delta_time, times_fired)
	if(N.stat == DEAD) //Dead necros don't heal
		return
	var/turf/my_turf = get_turf(N)
	if(my_turf.necro_corrupted) //Not standing on corruption? No heals
		N.heal_overall_damage(0.2 * delta_time, 0 * delta_time, BODYTYPE_ORGANIC)

//Does animations for regenerating a limb
/datum/species/necromorph/proc/regenerate_limb(mob/living/carbon/human/necromorph/H, limb, duration)
	var/image/LR = image(initial(H.class.ui_icon), H, "[limb]_regen")
	LR.plane = H.plane
	LR.layer = H.layer - 0.1 //Slightly below the layer of the mob, so that the healthy limb will draw over it
	flick_overlay(LR, GLOB.clients, duration)
