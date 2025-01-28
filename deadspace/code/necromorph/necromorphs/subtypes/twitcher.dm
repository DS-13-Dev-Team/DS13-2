/mob/living/carbon/human/necromorph/twitcher
	maxHealth = 175
	class = /datum/necro_class/twitcher
	necro_species = /datum/species/necromorph/twitcher
	pixel_x = -8
	base_pixel_x = -8
	///Pool for passive dodging of projectiles, gained passively over time and lost by dodging
	var/dodge_pool = 100
	//The absolute max the dodge_pool can have
	var/max_pool = 100
	///Chance of dodge_pool decreasing from bullet dodge
	var/dodge_pool_chance = 55
	///Amount dodge_pool decreases
	var/dodge_pool_usage = 8

/mob/living/carbon/human/necromorph/twitcher/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.twitcher_sounds[audio_type]), volume, vary, extra_range)

/datum/necro_class/twitcher
	display_name = "Twitcher"
	desc = "An elite soldier displaced in time, blinks around randomly and is difficult to hit. Charges extremely quickly"
	ui_icon = 'deadspace/icons/necromorphs/twitcher.dmi'
	necromorph_type_path = /mob/living/carbon/human/necromorph/twitcher
	tier = 1 //For the sake of sanity checks the normal twitcher is technically a T1
	biomass_cost = 150
	biomass_spent_required = 850
	melee_damage_lower = 10
	melee_damage_upper = 16
	armor = list(BLUNT = 45, PUNCTURE = 55, SLASH = 30, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 80)
	actions = list(
		/datum/action/cooldown/necro/shout,
		/datum/action/cooldown/necro/charge,
		/datum/action/cooldown/necro/charge/twitcher,
	)
	minimap_icon = "twitcher"
	implemented = TRUE
	nest_allowed = FALSE

/datum/species/necromorph/twitcher
	name = "Twitcher"
	id = SPECIES_NECROMORPH_TWITCHER
	speedmod = 0.8
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/necromorph/twitcher,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/necromorph/twitcher,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/twitcher,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/necromorph/twitcher,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/necromorph/twitcher,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/twitcher,
	)

/datum/species/necromorph/twitcher/get_scream_sound(mob/living/carbon/human/necromorph/twitcher)
	return pick(
		'deadspace/sound/effects/creatures/necromorph/twitcher/twitcher_shout_long_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/twitcher/twitcher_shout_long_5.ogg',
		'deadspace/sound/effects/creatures/necromorph/twitcher/twitcher_shout_long_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/twitcher/twitcher_shout_1.ogg',
	)

//Twitcher passively generates it's dodge back at a flat rate
/datum/species/necromorph/twitcher/spec_life(mob/living/carbon/human/necromorph/twitcher/necro, delta_time, times_fired)
	if(necro.stat == DEAD)
		return //Don't want it generating dodge while dead
	necro.dodge_pool = min(necro.dodge_pool + (0.6 * delta_time), necro.max_pool)
	..()

/datum/species/necromorph/twitcher/bullet_act(obj/projectile/P, mob/living/carbon/human/necromorph/twitcher/necro)
	if(necro.stat == DEAD)
		return ..() //We don't want the twitcher to dodge if he is dead

	if(prob(necro.dodge_pool))
		necro.visible_message(span_danger("[necro] twitches out of the way of [P]!"))
		necro.Shake(pick(15,-15),pick(15, -15), 1 SECONDS)
		playsound(necro, SFX_BULLET_MISS, 75, TRUE)
		if(prob(necro.dodge_pool_chance)) //Lowers dodge pool, moves twitcher out of the way if pool lowers
			necro.dodge_pool -= necro.dodge_pool_usage
			var/move_dir = pick(GLOB.alldirs)
			necro.Move(get_step(necro, move_dir), move_dir)
		return BULLET_ACT_FORCE_PIERCE
	return ..()
