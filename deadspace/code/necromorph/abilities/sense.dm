/datum/action/innate/sense
	name = "Sense the Unwhole"
	desc = "They cannot stop what is coming. Use to sense those who are not Whole."
	button_icon = 'icons/mob/actions/actions_cult.dmi' //TODO : Get our own sense button sprites
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	button_icon_state = "cult_mark"

//This is rewritten cultist harvester code kitbashed into the original sense code
//It works well enough for our purposes
/datum/action/innate/sense/Activate()
	var/mob/living/carbon/human/necromorph/sensor = owner
	var/thelist = sensor.marker.unwhole
	if(sensor.marker == null)
		return
	if(sensor.searching)
		desc = "They cannot stop what is coming. Use to sense those who are not Whole."
		button_icon_state = "cult_mark"
		sensor.searching = FALSE
		sensor.sense_target = null
		to_chat(sensor, "<span class='cult italic'>You are no longer sensing.</span>")
		sensor.clear_alert("necrosense")
		return
	else
		for(var/mob/living/found in thelist)
			found = pick(thelist)
			if(QDELETED(found))
				LAZYREMOVE(found, thelist) //He's dead, remove him from the list
				continue
			if(found.stat == DEAD)
				LAZYREMOVE(found, thelist) //He's dead, remove him from the list
				continue
			if(found.z != owner.z)
				continue //If we're not on the same floor ignore it
			sensor.sense_target = found
			to_chat(sensor, "<span class='cult italic'>You are now tracking your prey, [found.real_name] - find [found.p_them()]!</span>")
		if(!sensor.sense_target)
			to_chat(sensor, "<span class='cult italic'>There is nobody on this floor.</span>")
			return
		desc = "Activate to stop sensing."
		button_icon_state = "sintouch"
		sensor.searching = TRUE
		sensor.throw_alert("necrosense", /atom/movable/screen/alert/necrosense)
		sensor.play_necro_sound(SOUND_SPEECH, VOLUME_MID, TRUE, 3)
		play_effects()

/datum/action/innate/sense/proc/play_effects()
	set waitfor = FALSE

	var/obj/effect/temp_visual/circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40 //Offset it so it appears to be at our mob's head
	sleep(7)
	circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40
	sleep(7)
	circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40
