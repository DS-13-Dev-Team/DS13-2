/mob/living/carbon/human/necromorph/Initialize(mapload, obj/structure/marker/marker_master)
	. = ..()

	//AddComponent(/datum/component/seethrough_mob) //commented out until we can get this working on humans

	if(!marker_master)
		return INITIALIZE_HINT_QDEL

	fully_replace_character_name(real_name, dna.species.random_name())

	marker = marker_master
	marker_master.add_necro(src)
	var/datum/necro_class/temp = marker_master.necro_classes[class]
	temp.load_data(src)

/mob/living/carbon/human/necromorph/Destroy()
	evacuate()
	marker?.remove_necro(src)
	return ..()

//We should be always able to attack our opponents
/mob/living/carbon/human/necromorph/has_active_hand()
	return TRUE

//This messes with bloody hands, we don't want those on necros yet due to having no custom sprites for it
/mob/living/carbon/human/necromorph/update_worn_gloves()
	return

//This had to be moved from species due to code improvements
/mob/living/carbon/human/necromorph/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, forced = FALSE, spread_damage = FALSE, sharpness = NONE, attack_direction = null, attacking_item)
	var/mob/living/carbon/human/necromorph/H = src
	if(H.dodge_shield > 0)
		// Calculate amount of the damage that was blocked by the shield
		var/dodged_damage = min(H.dodge_shield, damage, damage * (100 - blocked) / 100)
		H.reduce_shield(dodged_damage)
		blocked += (dodged_damage / damage) * 100
	return ..()

/mob/living/carbon/human/necromorph/updatehealth(cause_of_death)
	if(status_flags & GODMODE)
		return

	set_health(maxHealth - getFireLoss() - getBruteLoss() - getCloneLoss())
	update_stat()
	SEND_SIGNAL(src, COMSIG_CARBON_HEALTH_UPDATE)

	dna?.species.spec_updatehealth(src)
	if(hud_used)
		var/datum/hud/necromorph/hud = hud_used
		hud.update_healthbar(src)

/mob/living/carbon/human/necromorph/revive(full_heal = FALSE, admin_revive = FALSE, excess_healing = 0)
	.=..()
	marker?.add_necro(src)

/mob/living/carbon/human/necromorph/set_stat(new_stat)
	.=..()
	update_sight()

/mob/living/carbon/human/necromorph/update_sight()
	. = ..()
	switch(stat)
		if(CONSCIOUS)
			see_in_dark = conscious_see_in_dark
		if(UNCONSCIOUS)
			see_in_dark = unconscious_see_in_dark
	//Otherwise we are dead and see_in_dark was handled in parent call

/mob/living/carbon/human/necromorph/death(gibbed, cause_of_death = "Unknown")
	if(stat == DEAD)
		return
	stop_sound_channel(CHANNEL_HEARTBEAT)
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(H)
		H.beat = BEAT_NONE

	silent = FALSE
	losebreath = 0

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")
	reagents.end_metabolization(src)

	set_stat(DEAD)
	unset_machine()
	timeofdeath = world.time
	tod = stationtime2text()
	evacuate()
	set_disgust(0)
	SetSleeping(0, 0)
	reset_perspective(null)
	reload_fullscreen()
	update_mob_action_buttons()
	update_damage_hud()
	update_health_hud()
	release_all_grabs()

	set_typing_indicator(FALSE)

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		client.move_delay = initial(client.move_delay)

	if(!gibbed)
		attach_rot()

	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_death()

	if(!QDELETED(dna)) //The gibbed param is bit redundant here since dna won't exist at this point if they got deleted.
		dna.species.spec_death(gibbed, src)

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
		log_message("has died (BRUTE: [src.getBruteLoss()], BURN: [src.getFireLoss()], TOX: [src.getToxLoss()], OXY: [src.getOxyLoss()], CLONE: [src.getCloneLoss()])", LOG_ATTACK)

	marker?.remove_necro(src)

/mob/living/carbon/human/necromorph/create_dna()
	dna = new /datum/dna(src)
	dna.species = new necro_species

/mob/living/carbon/human/necromorph/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(handle_death_check())
			death()
			return
		else
			set_stat(CONSCIOUS)
	update_damage_hud()
	update_health_hud()
	update_stamina_hud()

/// Check if the necromorph should die
/mob/living/carbon/human/necromorph/proc/handle_death_check()
	return (health <= 0 && !HAS_TRAIT(src, TRAIT_NODEATH))
