#region "obj_controller" Specific Macro Initialization

//
#macro	FIRST_BACKSPACE			0x00000001

// 
#macro	IS_FIRST_BACKSPACE		flags & FIRST_BACKSPACE

// 
#macro	FIRST_BSPACE_INTERVAL	15
#macro	NORM_BSPACE_INTERVAL	4

// 
#macro	ICON_SPACING			2

#endregion

#region Variable Initialization

// 
curState	= -1;
nextState	= -1;
lastState	= -1;
flags		= FIRST_BACKSPACE;

// 
camera = -1;

// 
mStartPanX	= 0;
mStartPanY	= 0;

// 
mouseGuiX	= 0;
mouseGuiY	= 0;

// 
tileData = ds_list_create();

// 
guiButtons			= ds_list_create();
selectedButton		= noone;
selectedBorder		= 1;
selectedIcon		= 0;

//
backspaceTimer		= 0;

// 
ds_list_add(guiButtons, 
	gui_button_create(2, 15, 96, 10, gui_button_select_map_name,	gui_button_draw_map_name),
	gui_button_create(2, 25, 96, 10, gui_button_select_map_width,	gui_button_draw_map_width),
);

#endregion

#region Utility Functions

/// @description 
/// @param {Real}	x				Position along the x axis in the room to create the tile object at.
/// @param {Real}	y				Position along the y axis in the room to create the tile object at.
/// @param {Real}	borderIndex		Value for the subsprite chosen as the tile's border from "spr_map_borders".
/// @param {Real}	iconIndex		Value for the subsprite chosen as the tile's icon from "spr_map_icons".
create_map_tile = function(_x, _y, _borderIndex, _iconIndex){
	var _cellX		= floor(_x / TILE_WIDTH);
	var _cellY		= floor(_y / TILE_HEIGHT);
	var _instance	= instance_create_depth(_cellX, _cellY, 0, obj_map_tile);
	with(_instance){
		image_index = _borderIndex;
		x			= _cellX * TILE_WIDTH;
		y			= _cellY * TILE_HEIGHT;
		icon		= _iconIndex;
		cellX		= _cellX;
		cellY		= _cellY;
	}
	ds_list_add(tileData, _instance);
}

/// @description 
/// @param {Id.Instance}	tileID		Instance ID for the map tile that will have its border/icon data updated.
update_map_tile = function(_tileID, _borderIndex, _iconIndex){
	var _index = ds_list_find_index(tileData, _tileID);
	if (_index == -1) {return;}
	
	// 
	with(tileData[| _index]){
		image_index = _borderIndex;
		icon		= _iconIndex;
	}
}

/// @description 
/// @param {Id.Instance}	tileID		Instance ID for the "obj_map_tile" that will be deleted.
delete_map_tile = function(_tileID){
	var _index = ds_list_find_index(tileData, _tileID);
	if (_index != -1){
		ds_list_delete(tileData, _index);
		instance_destroy(_tileID);
	}
}

/// @description 
/// @param {Real}	inputLimit	Total number of characters that can be stored in "global.inputString" for the current text input.
process_text_input = function(_inputLimit){
	var _length = string_length(global.inputString);
	if (_length > 0){ // Only process attempts to backspace if there are characters to remove from the input string.
		if (keyboard_check(vk_backspace)){
			backspaceTimer--;
			if (backspaceTimer <= 0){
				if (IS_FIRST_BACKSPACE){
					backspaceTimer = FIRST_BSPACE_INTERVAL;
					flags		  &= ~FIRST_BACKSPACE;
				} else{
					backspaceTimer = NORM_BSPACE_INTERVAL;
				}
				global.inputString = string_delete(global.inputString, _length, 1);
				keyboard_string	   = "";
			}
		} else{
			flags |= FIRST_BACKSPACE;
			backspaceTimer = 0;
		}
	}
	
	// 
	if (_length < _inputLimit && keyboard_string != ""){
		global.inputString += keyboard_string;
		keyboard_string = "";
	}
}

/// @description 
clear_selected_button = function(){
	nextState				= lastState;
	selectedButton.flags   &= ~BTN_SELECTED;
	selectedButton			= noone;
}

#endregion

#region State Functions

/// @description 
state_default = function(){
	// 
	var _mMiddleHeld = mouse_check_button(mb_middle);
	if (!_mMiddleHeld && mouseGuiX <= 100){
		nextState = state_within_gui;
		return;
	}
	
	// 
	if (_mMiddleHeld){
		if (mouse_check_button_pressed(mb_middle)){
			mStartPanX = mouse_x;
			mStartPanY = mouse_y;
			return;
		}
	
		// 
		var _mDiffX = mStartPanX - (window_mouse_get_x() / WINDOW_SCALE);
		var _mDiffY = mStartPanY - (window_mouse_get_y() / WINDOW_SCALE);
		camera_set_view_pos(camera, _mDiffX, _mDiffY);
		return;
	}
	
	// 
	if (mouse_x < 0 || mouse_y < 0 || mouse_x >= global.mapWidth * TILE_WIDTH || mouse_y >= global.mapHeight * TILE_HEIGHT) 
		return;
	var _tileID	= instance_position(mouse_x, mouse_y, obj_map_tile);
	var _tileEmpty = (_tileID == noone);

	// 
	if (keyboard_check(vk_shift)){
		// 
		if (mouse_check_button(mb_left)){
			if (_tileEmpty)	{create_map_tile(mouse_x, mouse_y, selectedIcon + 1, -1);}
			else			{update_map_tile(_tileID, selectedIcon + 1, -1);}
			return;
		}
	
		// 
		if (!_tileEmpty && mouse_check_button(mb_right))
			delete_map_tile(_tileID);
		return;
	}

	// 
	if (mouse_check_button_released(mb_left)){
		if (_tileEmpty)	{create_map_tile(mouse_x, mouse_y, selectedIcon + 1, -1);}
		else			{update_map_tile(_tileID, selectedIcon + 1, -1);}
		return;
	}

	// 
	if (!_tileEmpty && mouse_check_button_released(mb_right)) 
		delete_map_tile(_tileID);
}

/// @description 
state_within_gui = function(){
	// 
	if (mouseGuiX > 100){
		nextState = state_default;
		return;
	}
	
	// 
	var _select = mouse_check_button_released(mb_left);
	var _mGuiX	= mouseGuiX;
	var _mGuiY	= mouseGuiY;
	var _length = ds_list_size(guiButtons);
	for (var i = 0; i < _length; i++){
		with(guiButtons[| i]){
			if (!IS_BTN_ENABLED || _mGuiX <= xPos || _mGuiX > xPos + width || _mGuiY <= yPos || _mGuiY > yPos + height)
				continue; // Ignore all inactive buttons and ones that don't have the mouse cursor currently in their bounds.
			if (_select) {script_execute(selectFunction);}
			flags |= BTN_HIGHLIGHTED;
			break; // Exit loop as soon as the highlighted/selected button has been processed.
		}
	}
}

/// @description 
state_input_map_name = function(){
	// 
	if (keyboard_check_pressed(vk_escape)){
		clear_selected_button();
		global.inputString = "";
		return;
	}
	
	// 
	if (keyboard_check_pressed(vk_enter)){
		clear_selected_button();
		global.mapName		= global.inputString;
		global.inputString	= "";
		return;
	}
	
	//
	process_text_input(15);
}

/// @description 
state_input_map_width = function(){
	//
	if (keyboard_check_pressed(vk_escape)){
		clear_selected_button();
		global.inputString = "";
		return;
	}
	
	// 
	if (keyboard_check_pressed(vk_enter)){
		clear_selected_button();
		
		var _strNumbers = string_digits(global.inputString);
		if (_strNumbers != "") {global.mapWidth = clamp(real(_strNumbers), 1, 255);}
		
		global.inputString = "";
		return;
	}
	
	// 
	process_text_input(3);
}

#endregion

// 
nextState = state_default;