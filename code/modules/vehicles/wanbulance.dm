//EMT cart
/obj/vehicle/ridden/EMTcart
	name = "EMT Cart"
	desc = "A spare wagon with a new coat of paint just for the EMT."
	icon_state = "Wanbulance"
	key_type = /obj/item/key/emtkey

/obj/vehicle/ridden/EMTcart/Initialize()
	. = ..()
	update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-12, 7), TEXT_WEST = list( 12, 7)))

/obj/vehicle/ridden/EMTcart/Destroy()
	. = ..()

/obj/vehicle/ridden/janicart/update_icon()
	cut_overlays()