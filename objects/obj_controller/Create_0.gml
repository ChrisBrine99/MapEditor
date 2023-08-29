#region "obj_controller" Specific Macro Initialization

// 
#macro	FIRST_BACKSPACE			0x00000001

// 
#macro	IS_FIRST_BACKSPACE		flags & FIRST_BACKSPACE

//
#macro	STATE_DEFAULT			"Default"
#macro	STATE_INSIDE_GUI		"InsideGUI"
#macro	STATE_INPUT_MAP_NAME	"InputMapName"
#macro	STATE_INPUT_MAP_WIDTH	"InputMapWidth"
#macro	STATE_INPUT_MAP_HEIGHT	"InputMapHeight"
#macro	STATE_ACTIVATE_BORDERS	"ActivateBorders"
#macro	STATE_ACTIVATE_ICONS	"ActivateIcons"

// 
#macro	FIRST_BSPACE_INTERVAL	15
#macro	NORM_BSPACE_INTERVAL	4

// 
#macro	ICONS_PER_ROW			10
#macro	ICONS_PER_COLUMN		15
#macro	ICON_SPACING			1

#endregion

#region Variable Initialization

// 
curState	= -1;
nextState	= -1;
lastState	= -1;
flags		= FIRST_BACKSPACE;

//
stateFunctions = ds_map_create();

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
selectedIcon		= -1;

// 
backspaceTimer		= 0;

// 
firstBorderIndex	= 0;
totalBorderIndexes	= sprite_get_number(spr_map_borders) - 1;
firstIconIndex		= 0;
totalIconIndexes	= sprite_get_number(spr_map_icons);

// 
ds_list_add(guiButtons, 
	// Button for displaying on the GUI and adjusting the map's current name (This name is different from the
	// map's filename, which is chosen by the user when saving said map to an actual ".mm" file).
	gui_button_create(2, 15, 96, 10,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_NAME, 5, 16 // Halign, Valign, and color remain unaltered
		],	
		gui_button_draw_general, [
			gui_button_create_text_struct(5, 16, global.mapName, fa_left, fa_top, c_red),
			gui_button_create_text_struct(50, 6, "Input Map Name", fa_center)
		]
	),
	// Button for displaying on the GUI and adjusting the map's current width in tiles.
	gui_button_create(2, 25, 96, 10,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_WIDTH, 95, 26, fa_right, fa_top, c_yellow
		], 
		gui_button_draw_map_dimension, [
			gui_button_create_text_struct(95, 26, string(global.mapWidth), fa_right, fa_top, c_yellow),
			gui_button_create_text_struct(5, 16, "Enter Value (1 - 255)", fa_left, fa_top, c_red),
			"Width"
		]
	),
	// Button for displaying on the GUI and adjusting the map's current height in tiles.
	gui_button_create(2, 35, 96, 10,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_HEIGHT, 95, 36, fa_right, fa_top, c_yellow
		],
		gui_button_draw_map_dimension, [
			gui_button_create_text_struct(95, 36, string(global.mapHeight), fa_right, fa_top, c_yellow),
			gui_button_create_text_struct(5, 26, "Enter Value (1 - 255)", fa_left, fa_top, c_red),
			"Height"
		]
	),
	// 
	gui_button_create(2, 45, 96, 10,
		gui_button_select_general, [
			STATE_DEFAULT
		],
		gui_button_draw_general, [
			gui_button_create_text_struct(5, 46, "Color", fa_left, fa_top, c_white),
			noone
		],
		BTN_ENABLED
	),
	// Button for displaying the title "Tile". Its main purpose is to switch the current tile palette to the
	// border tiles, which allows the user to alter what base tile is added to the map when a cell is clicked.
	gui_button_create(4, 55, 4 + (TILE_WIDTH * 2), 13 + (TILE_HEIGHT * 2),
		gui_button_select_general, [
			STATE_ACTIVATE_BORDERS
		],
		gui_button_draw_general, [
			gui_button_create_text_struct(14, 56, "Tile", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		], 
		BTN_ENABLED	// This override removes default flag setup that allows button to be selected. 
	),
	// Button for displaying the title "Icon". Its main purpose is to switch the current tile palette to the
	// icon tiles, which allows the user to alter what icon is added to a tile when placed onto the map grid.
	gui_button_create(24, 55, 4 + (TILE_WIDTH * 2), 13 + (TILE_HEIGHT * 2),
		gui_button_select_general, [
			STATE_ACTIVATE_ICONS
		],
		gui_button_draw_general, [
			gui_button_create_text_struct(34, 56, "Icon", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		], 
		BTN_ENABLED	// This override removes default flag setup that allows button to be selected. 
	)
);

// 
firstBorderIndex = ds_list_size(guiButtons);
var _xOffset	 = 6;
var _yOffset	 = 86;
for (var i = 0; i < totalBorderIndexes; i++){
	if (i > 0 && i % ICONS_PER_ROW == 0){
		_xOffset  = 6;
		_yOffset += TILE_HEIGHT + ICON_SPACING;
	}
	
	ds_list_add(guiButtons,
		gui_button_create(
			_xOffset,
			_yOffset,
			TILE_WIDTH,
			TILE_HEIGHT,
			gui_button_select_map_borders,	[i + 1],
			gui_button_draw_tile_image,		[spr_map_borders, i + 1],
			BTN_ENABLED
		)
	);
	_xOffset += TILE_WIDTH + ICON_SPACING;
}

// 
firstIconIndex	= ds_list_size(guiButtons);
_xOffset		= 6;
_yOffset		= 86;
ds_list_add(guiButtons,
	gui_button_create(
		_xOffset,
		_yOffset,
		TILE_WIDTH,
		TILE_HEIGHT,
		gui_button_select_map_icons,	[-1],
		gui_button_draw_tile_image,		[-1, -1],
		0 // These buttons are all disabled by default.
	)
);

// 
_xOffset += TILE_WIDTH + ICON_SPACING;
for (var j = 0; j < totalIconIndexes; j++){
	ds_list_add(guiButtons,
		gui_button_create(
			_xOffset,
			_yOffset,
			TILE_WIDTH,
			TILE_HEIGHT,
			gui_button_select_map_icons,	[j],
			gui_button_draw_tile_image,		[spr_map_icons, j],
			0 // These buttons are all disabled by default.
		)
	);
	_xOffset += TILE_WIDTH + ICON_SPACING;
}
// 
totalIconIndexes++;

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
		x			= _cellX * TILE_WIDTH;
		y			= _cellY * TILE_HEIGHT;
		border		= _borderIndex;
		icon		= _iconIndex;
		cellX		= _cellX;
		cellY		= _cellY;
	}
	ds_list_add(tileData, _instance);
}

/// @description 
/// @param {Id.Instance}	tileID		Instance ID for the map tile that will have its border/icon data updated.
update_map_tile = function(_tileID, _borderIndex, _iconIndex){
	with(_tileID){
		border	= _borderIndex;
		icon	= _iconIndex;
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
	var _length = 0;
	with(global.inputText) {_length = string_length(text);}
	
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
				
				// 
				with(global.inputText){
					text = string_delete(text, _length, 1);
					keyboard_string	= "";
				}
			}
		} else{
			flags |= FIRST_BACKSPACE;
			backspaceTimer = 0;
		}
	}
	
	// 
	if (_length < _inputLimit && keyboard_string != ""){
		with(global.inputText){
			text += keyboard_string;
			keyboard_string = "";
		}
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

	if (keyboard_check(vk_control)){
		if (!_tileEmpty && mouse_check_button_pressed(mb_left)){
			var _borderID	= -1;
			var _iconID		= -1;
			with(_tileID){
				_borderID	= border;
				_iconID		= icon;
			}
			selectedBorder	= _borderID;
			selectedIcon	= _iconID;
		}
		return;
	}

	// 
	if (keyboard_check(vk_shift)){
		// 
		if (mouse_check_button(mb_left)){
			if (_tileEmpty)	{create_map_tile(mouse_x, mouse_y, selectedBorder, selectedIcon);}
			else			{update_map_tile(_tileID, selectedBorder, selectedIcon);}
			return;
		}
	
		// 
		if (!_tileEmpty && mouse_check_button(mb_right))
			delete_map_tile(_tileID);
		return;
	}

	// 
	if (mouse_check_button_released(mb_left)){
		if (_tileEmpty)	{create_map_tile(mouse_x, mouse_y, selectedBorder, selectedIcon);}
		else			{update_map_tile(_tileID, selectedBorder, selectedIcon);}
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
	var _select		= mouse_check_button_released(mb_left);
	var _mGuiX		= mouseGuiX;
	var _mGuiY		= mouseGuiY;
	var _buttonID	= noone;
	var _length		= ds_list_size(guiButtons);
	for (var i = 0; i < _length; i++){
		with(guiButtons[| i]){
			if (!IS_BTN_ENABLED || _mGuiX < xPos || _mGuiX > xPos + width || _mGuiY < yPos || _mGuiY > yPos + height)
				continue; // Ignore all inactive buttons and ones that don't have the mouse cursor currently in their bounds.
			if (_select){
				// 
				if (numSelectArgs == 0)	{script_execute(selectFunction);}
				else					{script_execute_ext(selectFunction, selectArgs);}
				
				// Only "select" the button if it can be selected. In this context, "selected" means any button
				// that activates some piece of code that runs for some duration of time. A button that doesn't 
				// change this controller object's state will not be set to selected.
				if (CAN_BTN_BE_SELECTED){
					flags      |= BTN_SELECTED;
					_buttonID	= ID;
				}
			}
			flags |= BTN_HIGHLIGHTED;
			break; // Exit loop as soon as the highlighted/selected button has been processed.
		}
	}
	selectedButton = _buttonID;
}

/// @description 
state_input_map_name = function(){
	// 
	if (keyboard_check_pressed(vk_escape)){
		clear_selected_button();
		with(global.inputText) {text = "";}
		return;
	}
	
	// 
	if (keyboard_check_pressed(vk_enter)){
		// 
		with(global.inputText){
			if (text == "") {continue;}
			global.mapName	= text;
			text			= "";
		}
		
		// 
		with(selectedButton)
			with(drawArgs[0]) {text = global.mapName;}
		clear_selected_button();
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
		with(global.inputText) {text = "";}
		return;
	}
	
	// 
	if (keyboard_check_pressed(vk_enter)){
		// 
		var _prevMapHeight = global.mapWidth;
		with(global.inputText){
			text			= string_digits(text);
			if (text == "") {continue;}
			global.mapWidth = clamp(real(text), 1, 255);
			text			= "";
		}
		
		// 
		with(selectedButton)
			with(drawArgs[0]) {text = string(global.mapWidth);}
		clear_selected_button();
	}
	
	// 
	process_text_input(3);
}

/// @description 
state_input_map_height = function(){
	//
	if (keyboard_check_pressed(vk_escape)){
		clear_selected_button();
		with(global.inputText) {text = "";}
		return;
	}
	
	// 
	if (keyboard_check_pressed(vk_enter)){
		// 
		var _prevMapHeight = global.mapHeight;
		with(global.inputText){
			text			 = string_digits(text);
			if (text == "") {continue;}
			global.mapHeight = clamp(real(text), 1, 255);
			text			 = "";
		}
		
		// 
		with(selectedButton)
			with(drawArgs[0]) {text = string(global.mapHeight);}
		clear_selected_button();
		return;
	}
	
	// 
	process_text_input(3);
}

/// @description 
state_activate_border_buttons = function(){
	for (var i = 0; i < totalBorderIndexes; i++){
		with(guiButtons[| firstBorderIndex + i]) {flags |= BTN_ENABLED;}
	}
	for (var i = 0; i < totalIconIndexes; i++){
		with(guiButtons[| firstIconIndex + i]) {flags &= ~BTN_ENABLED;}
	}
	nextState = lastState;
}

/// @description 
state_activate_icon_buttons = function(){
	for (var i = 0; i < totalIconIndexes; i++){
		with(guiButtons[| firstIconIndex + i]) {flags |= BTN_ENABLED;}
	}
	for (var i = 0; i < totalBorderIndexes; i++){
		with(guiButtons[| firstBorderIndex + i]) {flags &= ~BTN_ENABLED;}
	}
	nextState = lastState;
}

#endregion

// 
ds_map_add(stateFunctions, STATE_DEFAULT,			state_default);
ds_map_add(stateFunctions, STATE_INSIDE_GUI,		state_within_gui);
ds_map_add(stateFunctions, STATE_INPUT_MAP_NAME,	state_input_map_name);
ds_map_add(stateFunctions, STATE_INPUT_MAP_WIDTH,	state_input_map_width);
ds_map_add(stateFunctions, STATE_INPUT_MAP_HEIGHT,	state_input_map_height);
ds_map_add(stateFunctions, STATE_ACTIVATE_BORDERS,	state_activate_border_buttons);
ds_map_add(stateFunctions, STATE_ACTIVATE_ICONS,	state_activate_icon_buttons);

// 
nextState = state_default;