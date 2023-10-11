#define CURL_ANIMATION_TIME (0.8 SECONDS)
#define CURL_FORCED_DURATION (5 SECONDS)
#define CURL_FORCED_COOLDOWN (1.5 MINUTES)

/mob/living/carbon/human/necromorph/brute
	class = /datum/necro_class/brute
	necro_species = /datum/species/necromorph/brute
	pixel_x = -16
	base_pixel_x = -16
	status_flags = CANSTUN|CANUNCONSCIOUS
	var/armor_front = 30
	var/armor_flank = 20
	/// Multiplier for armor when curling
	var/curl_armor_mult = 1.5
	/// If brute is currently curling
	var/curling = FALSE
	/// If brute is currently forced to curl
	var/forced_curl = FALSE
	/// Time when we can be forced to curl again
	var/forced_curl_next = 0

	//Replace these with something better if possible
	var/next_attack_delay = 0
	var/spec_attack_delay = 25

/mob/living/carbon/human/necromorph/brute/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.brute_sounds[audio_type]), volume, vary, extra_range)

/mob/living/carbon/human/necromorph/brute/proc/spec_unarmedattack(datum/source, atom/target, proximity, modifiers)
	if(world.time >= next_attack_delay)
		play_necro_sound(SOUND_SHOUT, VOLUME_HIGH, 1, 3)
		if (istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/mob_target = target
			var/fling_dir = pick((dir & (NORTH|SOUTH)) ? list(WEST, EAST, dir|WEST, dir|EAST) : list(NORTH, SOUTH, dir|NORTH, dir|SOUTH)) //Fling them somewhere not behind nor ahead of the charger.
			var/fling_dist = rand(2,5)
			var/turf/destination = mob_target.loc
			var/turf/temp

			for(var/i in 1 to fling_dist)
				temp = get_step(destination, fling_dir)
				if(!temp)
					break
				destination = temp
			if(destination != mob_target.loc)
				mob_target.apply_damage(24, BRUTE)
				mob_target.throw_at(destination, fling_dist, 1, src, TRUE)
			next_attack_delay = spec_attack_delay + world.time
			return COMPONENT_CANCEL_ATTACK_CHAIN

	var/matrix/new_tranform = matrix()
	new_tranform.Scale(0.9)
	animate(src, transform = new_tranform, time = CURL_ANIMATION_TIME)
	play_necro_sound(SOUND_PAIN, 60, TRUE)
	sleep(CURL_ANIMATION_TIME)
	play_necro_sound(SOUND_FOOTSTEP, 40, TRUE)
	sleep(6)
	play_necro_sound(SOUND_FOOTSTEP, 40, TRUE)

/mob/living/carbon/human/necromorph/brute/proc/stop_curl()
	if(forced_curl)
		return
	curling = FALSE
	animate(src, transform = matrix(), time = CURL_ANIMATION_TIME)
	sleep(CURL_ANIMATION_TIME)
	REMOVE_TRAIT(src, TRAIT_RESTRAINED, src)

/mob/living/carbon/human/necromorph/brute/proc/end_forced_curl()
	forced_curl = FALSE
	stop_curl()

/datum/necro_class/brute
	display_name = "Brute"
	desc = "A powerful linebreaker and assault specialist, the brute can smash through almost any obstacle, and its tough \
	frontal armor makes it perfect for assaulting entrenched positions.\nVery vulnerable to flanking attacks"
	ui_icon = 'deadspace/icons/necromorphs/brute.dmi'
	necromorph_type_path = /mob/living/carbon/human/necromorph/brute
	tier = 3
	biomass_cost = 360
	biomass_spent_required = 950
	melee_damage_lower = 24
	melee_damage_upper = 28
	max_health = 510
	actions = list(
		/datum/action/cooldown/necro/slam,
		/datum/action/cooldown/necro/long_charge/brute,
		/datum/action/cooldown/necro/shoot/brute,
		/datum/action/cooldown/necro/curl,
	)
	minimap_icon = "brute"
	implemented = TRUE
	var/armor_front = 30
	var/armor_flank = 20

/datum/necro_class/brute/load_data(mob/living/carbon/human/necromorph/brute/necro)
	..()
	necro.armor_front = armor_front
	necro.armor_flank = armor_flank

/datum/species/necromorph/brute
	name = "Brute"
	id = SPECIES_NECROMORPH_BRUTE
	burnmod = 0.75
	stunmod = 0.15
	speedmod = 4
	species_mob_size = MOB_SIZE_LARGE
	special_step_sounds = list(
		'deadspace/sound/effects/footstep/brute_step_1.ogg',
		'deadspace/sound/effects/footstep/brute_step_2.ogg',
		'deadspace/sound/effects/footstep/brute_step_3.ogg',
		'deadspace/sound/effects/footstep/brute_step_4.ogg',
		'deadspace/sound/effects/footstep/brute_step_5.ogg',
		'deadspace/sound/effects/footstep/brute_step_6.ogg'
	)
	deathsound = list(
		'deadspace/sound/effects/creatures/necromorph/brute/brute_death.ogg'
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/necromorph/brute,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/necromorph/brute,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/brute,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/necromorph/brute,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/necromorph/brute,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/brute,
	)

/datum/species/necromorph/brute/get_scream_sound(mob/living/carbon/human/necromorph/brute)
	return pick(
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_1.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_3.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_extreme.ogg',
	)

/datum/species/necromorph/brute/spec_unarmedattack(mob/living/carbon/human/necromorph/brute/user, atom/target, modifiers)
	if(!user.combat_mode)
		return
	if(world.time < user.next_attack_delay)
		return
	user.next_attack_delay = user.spec_attack_delay + world.time
	user.play_necro_sound(SOUND_ATTACK, VOLUME_HIGH, 1, 3)
	if(isliving(target) && get_turf(target) != get_turf(user))
		var/mob/living/our_target = target
		var/throw_dir = pick(
			user.dir,
			turn(user.dir, 45),
			turn(user.dir, -45),
			) //Throwing them somewhere ahead of us
		var/throw_dist = rand(2,5)

		var/throw_x = our_target.x
		if(throw_dir & WEST)
			throw_x += throw_dist
		else if(throw_dir & EAST)
			throw_x -= throw_dist

		var/throw_y = our_target.y
		if(throw_dir & NORTH)
			throw_y += throw_dist
		else if(throw_dir & SOUTH)
			throw_y -= throw_dist

		throw_x = clamp(throw_x, 1, world.maxx)
		throw_y = clamp(throw_y, 1, world.maxy)

		our_target.safe_throw_at(locate(throw_x, throw_y, our_target.z), throw_dist, 1, user, TRUE)

	return ..()

/datum/species/necromorph/brute/apply_damage(damage, damagetype, def_zone, blocked, mob/living/carbon/human/necromorph/brute/H, forced, spread_damage, sharpness, attack_direction)
	var/reduced = 0
	switch(turn(attack_direction, dir2angle(H.dir)))
		if(NORTH)
			reduced = damage * ((100-H.armor_front)/100)
		if(NORTHEAST, NORTHWEST)
			reduced = damage * ((100-((H.armor_front+H.armor_flank)/2))/100)
		if(EAST, WEST)
			reduced = damage * ((100-H.armor_flank)/100)
		if(SOUTHEAST, SOUTHWEST)
			reduced = damage * ((100-(H.armor_flank/2))/100)
		if(SOUTH)
			INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human/necromorph/brute, start_curl), TRUE)
			to_chat(H, span_danger("You reflexively curl up in panic"))
			return ..()
	if(H.curling)
		reduced *= H.curl_armor_mult
	blocked += reduced
	return ..()

#define WINDUP_TIME 1.25 SECONDS

/datum/action/cooldown/necro/shoot/brute
	name = "Bio-bomb"
	desc = "A moderate-strength projectile for longrange shooting."
	cooldown_time = 12 SECONDS
	windup_time = WINDUP_TIME
	projectiletype = /obj/projectile/bullet/biobomb/brute

/datum/action/cooldown/necro/shoot/brute/pre_fire(atom/target)
	var/x_direction = 0
	if (target.x > owner.x)
		x_direction = -1
	else if (target.x < owner.x)
		x_direction = 1

	//We do the windup animation. This involves the user slowly rising into the air, and tilting back if striking horizontally
	animate(
		owner,
		transform = turn(matrix(), 25*x_direction),
		pixel_x = owner.base_pixel_x + 8*x_direction,
		time = WINDUP_TIME,
		flags = ANIMATION_PARALLEL
	)

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, src)

/datum/action/cooldown/necro/shoot/brute/post_fire()
	sleep(0.4 SECONDS)
	animate(owner, transform = matrix(), pixel_x = owner.base_pixel_x, time = 0.8 SECOND, flags = ANIMATION_PARALLEL)
	sleep(0.8 SECONDS)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, src)

#undef WINDUP_TIME

/obj/projectile/bullet/biobomb/brute
	name = "acid bolt"
	icon = 'deadspace/icons/obj/projectiles.dmi'
	icon_state = "acid_large"

	damage = 10
	speed = 0.8
	pixel_speed_multiplier = 0.5

	acid_type = /datum/reagent/toxin/acid/fluacid
	acid_amount = 3

#undef CURL_ANIMATION_TIME
#undef CURL_FORCED_DURATION
#undef CURL_FORCED_COOLDOWN
