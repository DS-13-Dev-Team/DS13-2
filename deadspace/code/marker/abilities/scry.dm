/datum/action/cooldown/necro/psy/scry
	name = "Scry"
	desc = "Reveals a targeted area in a 6 tile radius for a duration of 1 minute. Creates a spooky ethereal glow there too."
	button_icon_state = "scry"
	cost = 1
	click_through_static = TRUE
	marker_flags = SIGNAL_ABILITY_PRE_ACTIVATION

/datum/action/cooldown/necro/psy/scry/post_activation
	cost = 15
	marker_flags = SIGNAL_ABILITY_POST_ACTIVATION

/datum/action/cooldown/necro/psy/scry/Activate(atom/target)
	var/mob/camera/marker_signal/caller = owner
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		..()
		new /obj/effect/temp_visual/scry(target_turf, caller.marker.markernet)
		return TRUE

/obj/effect/temp_visual/scry
	anchored = TRUE
	duration = 1 MINUTES

/obj/effect/temp_visual/scry/Initialize(mapload, datum/markernet/visual_net)
	. = ..()
	if(visual_net)
		visual_net.addVisionSource(src, VISION_SOURCE_RANGE)
	else
		return INITIALIZE_HINT_QDEL

/obj/effect/temp_visual/scry/can_see_marker()
	return RANGE_TURFS(6, src)

/datum/action/cooldown/necro/psy/sense
	name = "Sense Survivors"
	desc = "Senses for living survivors and sentient creatures in the world. The Marker automatically does this on activation. Recommend to use if the necromorphs cannot find the last survivors."
	button_icon_state = "scry"
	cost = 250
	cooldown_time = 20 MINUTES //You probably only have to use this ability once in a round, so the cooldown will be big
	click_through_static = TRUE
	marker_flags = SIGNAL_ABILITY_POST_ACTIVATION|SIGNAL_ABILITY_MARKER_ONLY

//This just is a roundabout way for the master signal to add to the survivor list mid-round
/datum/action/cooldown/necro/psy/sense/Activate(atom/target)
	var/mob/camera/marker_signal/caller = owner
	caller.marker.sense_survivors()
