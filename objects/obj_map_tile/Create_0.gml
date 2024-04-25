/*#region Macro Initialization

// ------------------------------------------------------------------------------------------------------- //
//	
// ------------------------------------------------------------------------------------------------------- //

#macro	EAST_DOOR				0x08000000
#macro	NORTH_DOOR				0x10000000
#macro	WEST_DOOR				0x20000000
#macro	SOUTH_DOOR				0x40000000
#macro	HIDDEN_AREA				0x80000000

// ------------------------------------------------------------------------------------------------------- //
//	
// ------------------------------------------------------------------------------------------------------- //

#macro	HAS_EASTERN_DOOR		(flags & EAST_DOOR)
#macro	HAS_NORTHERN_DOOR		(flags & NORTH_DOOR)
#macro	HAS_WESTERN_DOOR		(flags & WEST_DOOR)
#macro	HAS_SOUTHERN_DOOR		(flags & SOUTH_DOOR)
#macro	IS_HIDDEN_AREA			(flags & HIDDEN_AREA)

// ------------------------------------------------------------------------------------------------------- //
//	
// ------------------------------------------------------------------------------------------------------- //

#macro	DOOR_TYPE				0x00
#macro	DOOR_FLAG				0x01

// ------------------------------------------------------------------------------------------------------- //
//	
// ------------------------------------------------------------------------------------------------------- //

#macro	EASTERN_DOORWAY			0x00
#macro	NORTHERN_DOORWAY		0x01
#macro	WESTERN_DOORWAY			0x02
#macro	SOUTHERN_DOORWAY		0x03

// ------------------------------------------------------------------------------------------------------- //
//	
// ------------------------------------------------------------------------------------------------------- //

#macro	DOOR_ID_INVALID			0x00
#macro	DOOR_ID_ANY				0x01
#macro	DOOR_ID_ICEBEAM			0x02
#macro	DOOR_ID_WAVEBEAM		0x03
#macro	DOOR_ID_PLASMABEAM		0x04
#macro	DOOR_ID_MISSILE			0x10
#macro	DOOR_ID_SUPER_MISSILE	0x11
#macro	DOOR_ID_POWER_BOMB		0x20
#macro	DOOR_ID_LOCKED_FLAG		0x30
#macro	DOOR_ID_LOCKED_FOREVER	0x31

#endregion

#region Unique Variable Initialization

// 
flags	= 0;

// 
color	= global.mapColor;

// 
cellX	= 0;
cellY	= 0;
border	= -1;
icon	= -1;

// 
doorData = [
	[ DOOR_ID_INVALID, EVENT_FLAG_INVALID ],	// Eastern Doorway
	[ DOOR_ID_INVALID, EVENT_FLAG_INVALID ],	// Northern Doorway
	[ DOOR_ID_INVALID, EVENT_FLAG_INVALID ],	// Western Doorway
	[ DOOR_ID_INVALID, EVENT_FLAG_INVALID ]		// Southern Doorway
];

#endregion

#region Function Initialization

/// @description 
/// @param {Real}	doorIndex	The desired door to render onto the map tile.
/// @param {Real}	x			Offset relative to the tile's x position to draw the door at. 
/// @param {Real}	y			Offset relative to the tile's y position to draw the door at. 
draw_doorway = function(_doorIndex, _x, _y){
	var _doorID = doorData[_doorIndex][DOOR_TYPE];
	if (_doorID == DOOR_ID_INVALID)
		return;
	
	// 
	var _color = door_get_color(_doorID);
	if (_doorIndex == NORTHERN_DOORWAY || _doorIndex == SOUTHERN_DOORWAY){
		draw_sprite_ext(spr_rectangle, 0, _x, _y, 2, 1, 0.0, _color, 1.0);
		return;
	}
	draw_sprite_ext(spr_rectangle, 0, _x, _y, 1, 2, 0.0, _color, 1.0);
}

/// @description 
/// @param {Real}	doorID
door_get_name = function(_doorID){
	switch(_doorID){
		case DOOR_ID_ANY:				return "Any";
		case DOOR_ID_ICEBEAM:			return "Ice";
		case DOOR_ID_WAVEBEAM:			return "Wave";
		case DOOR_ID_PLASMABEAM:		return "Plasma";
		case DOOR_ID_MISSILE:			return "Missile";
		case DOOR_ID_SUPER_MISSILE:		return "S. Missile";
		case DOOR_ID_POWER_BOMB:		return "Power Bomb";
		case DOOR_ID_LOCKED_FLAG:		return "Locked Flag";
		case DOOR_ID_LOCKED_FOREVER:	return "Locked Forever";
	}
	
	return "";
}

/// @description 
/// @param {Real}	doorID		
door_get_color = function(_doorID){
	switch(_doorID){
		case DOOR_ID_ANY:				return 0xF87800;
		case DOOR_ID_ICEBEAM:			return 0xFCE478;
		case DOOR_ID_WAVEBEAM:			return 0xFC4468;
		case DOOR_ID_PLASMABEAM:		return 0x001488;
		case DOOR_ID_MISSILE:			return 0x7C7C7C;
		case DOOR_ID_SUPER_MISSILE:		return 0x18F8B8;
		case DOOR_ID_POWER_BOMB:		return 0x78D8F8;
		case DOOR_ID_LOCKED_FLAG:
		case DOOR_ID_LOCKED_FOREVER:	return 0x202020;
	}
	
	// By default solid white is returned; turning the doorway into a complete wall when rendered.
	return 0xFFFFFF;
}

#endregion