#define EXT_BOUND 1
#define INT_BOUND 2
#define NO_BOUND 3

#define SIPHONING 0
#define RELEASING 1

/obj/machinery/atmospherics/components/unary/vent_pump
	icon_state = "vent_map-2"

	name = "air vent"
	desc = "Has a valve and pump attached to it."

	use_power = IDLE_POWER_USE
	can_unwrench = FALSE
	welded = FALSE
	level = 1
	layer = GAS_SCRUBBER_LAYER
	atom_flags = SHUTTLE_IMMUNE

	var/pump_direction = RELEASING

	var/pressure_checks = EXT_BOUND
	var/external_pressure_bound = ONE_ATMOSPHERE
	var/internal_pressure_bound = 0
	// EXT_BOUND: Do not pass external_pressure_bound
	// INT_BOUND: Do not pass internal_pressure_bound
	// NO_BOUND: Do not pass either

	var/radio_filter_out
	var/radio_filter_in

	pipe_state = "uvent"

/obj/machinery/atmospherics/components/unary/vent_pump/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)

	if(welded)
		icon_state = "vent_welded"
		return

	if(!nodes[1] || !on || !is_operational())
		if(icon_state == "vent_welded")
			icon_state = "vent_off"
			return

		if(pump_direction & RELEASING)
			icon_state = "vent_out-off"
		else // pump_direction == SIPHONING
			icon_state = "vent_in-off"
		return

	if(icon_state == ("vent_out-off" || "vent_in-off" || "vent_off"))
		if(pump_direction & RELEASING)
			icon_state = "vent_out"
			flick("vent_out-starting", src)
		else // pump_direction == SIPHONING
			icon_state = "vent_in"
			flick("vent_in-starting", src)
		return

	if(pump_direction & RELEASING)
		icon_state = "vent_out"
	else // pump_direction == SIPHONING
		icon_state = "vent_in"


/obj/machinery/atmospherics/components/unary/vent_pump/plasmacutter_act(mob/living/user, obj/item/W)
	if(isplasmacutter(W))
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(!welded)
			to_chat(user, span_warning("\The [P] can only cut open welds!"))
			return FALSE
		if(!(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)))
			return FALSE
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_VLOW_MOD, NONE, src, BUSY_ICON_BUILD))
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Vents require much less charge
			welded = FALSE
			update_icon()
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/welder_act(mob/living/user, obj/item/I)
	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(WT.remove_fuel(1, user))
			user.visible_message(span_notice("[user] starts welding [src] with [WT]."), \
			span_notice("You start welding [src] with [WT]."))
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(I.use_tool(src, user, 5 SECONDS, 1, 25, null, BUSY_ICON_BUILD)) // todo clean this proc up its so bay-ey :(
				if(!welded)
					user.visible_message(span_notice("[user] welds [src] shut."), \
					span_notice("You weld [src] shut."))
					welded = TRUE
				else
					user.visible_message(span_notice("[user] welds [src] open."), \
					span_notice("You weld [src] open."))
					welded = FALSE
				update_icon()
				pipe_vision_img = image(src, loc, dir = dir)
				SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
				return TRUE
			else
				to_chat(user, span_warning("[WT] needs to be on to start this task."))
				return FALSE
		else
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_pump/power_change()
	..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_pump/can_crawl_through()
	return !welded

/obj/machinery/atmospherics/components/unary/vent_pump/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	if(!welded || !(do_after(xeno_attacker, 2 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE)))
		return
	xeno_attacker.visible_message("[xeno_attacker] furiously claws at [src]!", "We manage to clear away the stuff blocking the vent", "You hear loud scraping noises.")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, dir = dir)
	SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)


/obj/machinery/atmospherics/components/unary/vent_pump/AltClick(mob/user)
	if(!isliving(user))
		return
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		xeno_user.handle_ventcrawl(src, xeno_user.xeno_caste.vent_enter_speed, xeno_user.xeno_caste.silent_vent_crawl)
		return
	var/mob/living/living_user = user
	living_user.handle_ventcrawl(src)


/obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = EQUIP

// mapping

/obj/machinery/atmospherics/components/unary/vent_pump/Initialize(mapload)
	. = ..()
	GLOB.atmospumps += src

/obj/machinery/atmospherics/components/unary/vent_pump/layer1
	piping_layer = 1
	icon_state = "vent_map-1"

/obj/machinery/atmospherics/components/unary/vent_pump/layer3
	piping_layer = 3
	icon_state = "vent_map-3"

/obj/machinery/atmospherics/components/unary/vent_pump/layer4
	piping_layer = 4
	icon_state = "vent_map-3"

/obj/machinery/atmospherics/components/unary/vent_pump/on
	on = TRUE
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer1
	piping_layer = 1
	icon_state = "vent_map_on-1"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer3
	piping_layer = 3
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon
	pump_direction = SIPHONING
	pressure_checks = INT_BOUND
	internal_pressure_bound = 4000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/Destroy()
	. = ..()
	GLOB.atmospumps -= src

#undef INT_BOUND
#undef EXT_BOUND
#undef NO_BOUND

#undef SIPHONING
#undef RELEASING
