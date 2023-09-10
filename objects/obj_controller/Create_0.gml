#region "obj_controller" Specific Macro Initialization

// 
#macro	FIRST_BACKSPACE			0x00000001
#macro	UPDATE_REQUIRED			0x00000002
#macro	UPDATE_SURF_BUFFER		0x00000004

// 
#macro	IS_FIRST_BACKSPACE		flags & FIRST_BACKSPACE
#macro	IS_UPDATE_REQUIRED		flags & UPDATE_REQUIRED
#macro	CAN_UPDATE_SURF_BUFFER	flags & UPDATE_SURF_BUFFER

//
#macro	STATE_DEFAULT			"Default"
#macro	STATE_INSIDE_GUI		"InsideGUI"
#macro	STATE_INPUT_MAP_NAME	"InputMapName"
#macro	STATE_INPUT_MAP_WIDTH	"InputMapWidth"
#macro	STATE_INPUT_MAP_HEIGHT	"InputMapHeight"
#macro	STATE_ACTIVATE_BORDERS	"ActivateBorders"
#macro	STATE_ACTIVATE_ICONS	"ActivateIcons"
#macro	STATE_ACTIVATE_DOORS	"ActivateDoors"

//
#macro	MAX_ZOOM_LEVEL			6.0
#macro	MIN_ZOOM_LEVEL			0.5

// 
#macro	FIRST_BSPACE_INTERVAL	15.0
#macro	NORM_BSPACE_INTERVAL	4.0

// 
#macro	ICONS_PER_ROW			10
#macro	ICONS_PER_COLUMN		15
#macro	ICON_SPACING			1

// 
#macro	MAX_DOORS_PER_TILE		4

#endregion

#region Variable Initialization

// 
curState	= -1;
nextState	= -1;
lastState	= -1;
flags		= FIRST_BACKSPACE;
deltaTime	= 0.0;

// 
stateFunctions = ds_map_create();

// 
gridSurf		= -1;
tileSurf		= -1;
tileSurfBuffer	= buffer_create(
	global.mapWidth * TILE_WIDTH * 
	global.mapHeight * TILE_HEIGHT *
	4, buffer_wrap, buffer_f32);

// 
camera		= -1;
zoomLevel	= 1.0;
sZoomLevel	= "1x ";

// 
mStartPanX	= 0;
mStartPanY	= 0;

// 
mouseCellX	= 0;
mouseCellY	= 0;
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
backspaceTimer		= 0.0;
bufferUpdateTimer	= 0.0;

// 
firstBorderIndex	= 0;
totalBorderIndexes	= sprite_get_number(spr_map_borders) - 1;
firstIconIndex		= 0;
totalIconIndexes	= sprite_get_number(spr_map_icons);
firstDoorIndex		= 0;

// 
ds_list_add(guiButtons, 
	// 
	gui_button_create(2, 2, 31, 9,
		gui_button_new_file, [],
		gui_button_draw_general, [
			gui_button_create_text_struct("New", 17, 3, "New", fa_center, fa_top, c_white),
			noone
		],
		BTN_ENABLED
	),
	// 
	gui_button_create(34, 2, 32, 9,
		gui_button_load_file, [],
		gui_button_draw_general, [
			gui_button_create_text_struct("Load", 49, 3, "Load", fa_center, fa_top, c_white),
			noone
		],
		BTN_ENABLED
	),
	// 
	gui_button_create(67, 2, 31, 9,
		gui_button_save_file, [],
		gui_button_draw_general, [
			gui_button_create_text_struct("Save", 83, 3, "Save", fa_center, fa_top, c_white),
			noone
		],
		BTN_ENABLED
	),
	// Button for displaying on the GUI and adjusting the map's current name (This name is different from the
	// map's filename, which is chosen by the user when saving said map to an actual ".mm" file).
	gui_button_create(2, 12, 96, 9,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_NAME, 5, 13 // Halign, Valign, and color remain unaltered
		],	
		gui_button_draw_general, [
			gui_button_create_text_struct("MapName", 5, 13, global.mapName, fa_left, fa_top, c_red),
			gui_button_create_text_struct("MapNameInfo", 50, 3, "Input Map Name", fa_center)
		]
	),
	// Button for displaying on the GUI and adjusting the map's current width in tiles.
	gui_button_create(2, 22, 96, 9,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_WIDTH, 95, 23, fa_right, fa_top, c_yellow
		], 
		gui_button_draw_map_dimension, [
			gui_button_create_text_struct("MapWidth", 95, 23, string(global.mapWidth), fa_right, fa_top, c_yellow),
			gui_button_create_text_struct("MapWidthInfo", 5, 13, "Enter Value (1 - 255)", fa_left, fa_top, c_red),
			"Width"
		]
	),
	// Button for displaying on the GUI and adjusting the map's current height in tiles.
	gui_button_create(2, 32, 96, 9,
		gui_button_select_general_has_input, [
			STATE_INPUT_MAP_HEIGHT, 95, 33, fa_right, fa_top, c_yellow
		],
		gui_button_draw_map_dimension, [
			gui_button_create_text_struct("MapHeight", 95, 33, string(global.mapHeight), fa_right, fa_top, c_yellow),
			gui_button_create_text_struct("MapHeightInfo", 5, 23, "Enter Value (1 - 255)", fa_left, fa_top, c_red),
			"Height"
		]
	),
	// Button for displaying the title "Tile". Its main purpose is to switch the current tile palette to the
	// border tiles, which allows the user to alter what base tile is added to the map when a cell is clicked.
	gui_button_create(4, 52, 4 + (TILE_WIDTH * 2), 13 + (TILE_HEIGHT * 2),
		gui_button_select_general, [
			STATE_ACTIVATE_BORDERS
		],
		gui_button_draw_general, [
			gui_button_create_text_struct("Tile", 14, 53, "Tile", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		], 
		BTN_ENABLED	// This override removes default flag setup that allows button to be selected. 
	),
	// Button for displaying the title "Icon". Its main purpose is to switch the current tile palette to the
	// icon tiles, which allows the user to alter what icon is added to a tile when placed onto the map grid.
	gui_button_create(25, 52, 4 + (TILE_WIDTH * 2), 13 + (TILE_HEIGHT * 2),
		gui_button_select_general, [
			STATE_ACTIVATE_ICONS
		],
		gui_button_draw_general, [
			gui_button_create_text_struct("Icon", 35, 53, "Icon", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		],
		BTN_ENABLED	// This override removes default flag setup that allows button to be selected. 
	),
	// 
	gui_button_create(46, 57, 52, 9,
		gui_button_select_general, [
			STATE_ACTIVATE_DOORS
		],
		gui_button_draw_general, [
			gui_button_create_text_struct("Doors", 72, 58, "Doors", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		],
		BTN_ENABLED	// This override removes default flag setup that allows button to be selected. 
	),
	//
	gui_button_create(46, 67, 52, 9,
		gui_button_select_general, [
			STATE_DEFAULT
		], 
		gui_button_draw_general, [
			gui_button_create_text_struct("Flags", 72, 68, "Flags", fa_center),
			noone	// An "Input Text Struct" header isn't required, so this can be left blank.
		],
		BTN_ENABLED // This override removes default flag setup that allows button to be selected. 
	),
);

// Loop through all the "frames" found within "spr_map_borders"; creating a GUI button for each one that the
// user can then select to apply that tile border onto their to-be-placed tile. Since there are more than 10
// buttons to create (10 is the limit per row of buttons), a check within the loop will reset the x offset and
// shift the y offset downward so newly created GUI buttons are added to a new row.
firstBorderIndex = ds_list_size(guiButtons);
var _xOffset	 = 6;
var _yOffset	 = 83;
for (var i = 0; i < totalBorderIndexes; i++){
	// Reset the x offset; shift y offset down by the required spacing amount to initialize a new row of tile
	// border buttons.
	if (i > 0 && i % ICONS_PER_ROW == 0){
		_xOffset  = 6;
		_yOffset += TILE_HEIGHT + ICON_SPACING;
	}
	
	// Create the button and then shift the x offset value by the required spacing for the next button in the
	// list of tile border GUI buttons.
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

// Before looping to create the rest of the tile icon buttons, the first button will be created to allow the
// user to remove the currently selected icon from the to-be-placed map tile. The local x and y offset variables
// are reset back to the top-left region of the tile display on the GUI for this button to use.
firstIconIndex	= ds_list_size(guiButtons);
_xOffset		= 6;
_yOffset		= 83;
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

// Loop through and create a new GUI button for each image within the "spr_map_icons" sprite. The initial offset
// along the x axis is adjusted to make room for the black button that exists to allow the user to remove the
// currently selected icon so any created map tiles don't use an icon when placed.
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
// Increment by one to compensate for the "icon" button that was created prior to the loop that created a new
// button for each image found within "spr_map_icons". Otherwise, the last icon wouldn't appear to the user
// for selection when they open the icon section menu.
totalIconIndexes++;

// 
firstDoorIndex = ds_list_size(guiButtons);

#endregion

#region Utility Functions

/// @description 
/// @param {Real}	width		Size of the background grid surface in tiles along the x axis.
/// @param {Real}	height		Size fo the background grid surface in tiles along the y axis.
/// @param {Real}	backAlpha	Opacity level for the black background that exists behind the grid itself.
build_grid_surface = function(_width, _height, _backAlpha){
	// 
	gridSurf = surface_create(_width * TILE_WIDTH, _height * TILE_HEIGHT);

	// 
	surface_set_target(gridSurf);
	draw_clear_alpha(c_black, 0.0);
	draw_sprite_ext(spr_rectangle, 0, 0, 0, _width * TILE_WIDTH, _height * TILE_HEIGHT, 0, c_black, _backAlpha);
	
	// 
	for (var yy = 0; yy < _height; yy++){
		for (var xx = 0; xx < _width; xx++)
			draw_sprite(spr_map_borders, 0, xx * TILE_WIDTH, yy * TILE_HEIGHT);
	}
	surface_reset_target();
}

/// @description 
/// @param {Real}	width		Size of the map tile surface in tile cells along the x axis.
/// @param {Real}	height		Size of the map tile surface in tile cells along the y axis.
build_tile_surface = function(_width, _height){
	// 
	if (!surface_exists(tileSurf)) {tileSurf = surface_create(_width * TILE_WIDTH, _height * TILE_HEIGHT);}
	else {surface_resize(tileSurf, _width * TILE_WIDTH, _height * TILE_HEIGHT);}
	
	// 
	if (instance_number(obj_map_tile) == 0) {return;}
	
	// 
	var _bufferSize = _width * TILE_WIDTH * _height * TILE_HEIGHT * 4;
	buffer_resize(tileSurfBuffer, _bufferSize);
	buffer_fill(tileSurfBuffer, 0, buffer_f32, 0.0, _bufferSize);
	
	// 
	surface_set_target(tileSurf);
	draw_clear_alpha(c_black, 0.0);
	with(obj_map_tile) {event_perform(ev_draw, 0);}
	surface_reset_target();
}

/// @description 
/// @param {Id.Instance} tileID	
update_tile_surface = function(_tileID){
	// 
	surface_set_target(tileSurf);
	with(_tileID) {event_perform(ev_draw, 0);}
	surface_reset_target();
	
	// 
	flags |= UPDATE_REQUIRED;
	bufferUpdateTimer = 15;
}

/// @description 
/// @param {Id.Instance} tileID
remove_tile_from_surface = function(_tileID){
	// 
	gpu_set_blendmode_ext(bm_zero, bm_zero);
	surface_set_target(tileSurf);
	with(_tileID) {draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 0, c_white, 1.0);}
	surface_reset_target();
	gpu_set_blendmode(bm_normal);
	
	// 
	flags |= UPDATE_REQUIRED;
	bufferUpdateTimer = 15;
}

/// @description Creates a new map tile instance at the provided call coordinates. This cell coordiante is
/// calculated by taking the position passed in as an argument and dividing both values by the width and height
/// of a map tile; truncating that result to remove the decimal value.
/// @param {Real}	cellX			Position along the x axis in the room to create the tile object at.
/// @param {Real}	cellY			Position along the y axis in the room to create the tile object at.
/// @param {Real}	borderIndex		Value for the subsprite chosen as the tile's border from "spr_map_borders".
/// @param {Real}	iconIndex		Value for the subsprite chosen as the tile's icon from "spr_map_icons".
/// @param {Real}	flags			Flags that determine how the map tile appears in-game and within the editor.
create_map_tile = function(_cellX, _cellY, _borderIndex, _iconIndex, _flags){
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

/// @description Updates a map tile with new border and icon information; allowing an already placed tile in
/// the map to be quickly updated instead of the user having to completely remove it to place a new tile that
/// matches the border/icon setup they desire.
/// @param {Id.Instance}	tileID		Instance ID for the map tile that will have its border/icon data updated.
update_map_tile = function(_tileID, _borderIndex, _iconIndex){
	with(_tileID){
		border	= _borderIndex;
		icon	= _iconIndex;
	}
}

/// @description Removes the desired obj_map_tile instance from the current map if the instance ID provided is
/// found within the ds_list that manages all existing tile objects.
/// @param {Id.Instance}	tileID		Instance ID for the "obj_map_tile" that will be deleted.
delete_map_tile = function(_tileID){
	var _index = ds_list_find_index(tileData, _tileID);
	if (_index != -1){
		remove_tile_from_surface(_tileID);
		ds_list_delete(tileData, _index);
		instance_destroy(_tileID);
	}
}

/// @description 
remove_all_tiles = function(){
	// 
	var _index = ds_list_size(tileData) - 1;
	while(_index != -1){
		instance_destroy(tileData[| _index]);
		ds_list_delete(tileData, _index);
		_index--;
	}
	
	// 
	buffer_fill(tileSurfBuffer, 0, buffer_f32, 0.0, buffer_get_size(tileSurfBuffer));
	if (surface_exists(tileSurf)) {surface_free(tileSurf);}
}

/// @description Removes obj_map_tile objects from the current map that exist outside of the current bounds of
/// the map. A tile is considered outside these bounds if its cell position matches of exceeds either the x
/// or y cell limits.
/// @param {Real}	cellLimitX	Total width of the current map bounds in cells.
/// @param {Real}	cellLimitY	Total height of the current map bounds in cells.
remove_out_of_bounds_tiles = function(_cellLimitX, _cellLimitY){
	var _tileData	= tileData;	// Store locally for quick reference within each "obj_map_tile" instance.
	var _length		= ds_list_size(tileData);
	for (var i = 0; i < _length; i++){
		with(tileData[| i]){
			if (cellX >= _cellLimitX || cellY >= _cellLimitY){
				ds_list_delete(_tileData, i);
				instance_destroy(id);
				_length--;	// Subtract length and i by one to compensate for index delete in middle of list.
				i--;
			}
		}
	}
}

/// @description 
/// @param {Real}	modifier	
update_zoom_level = function(_modifier){
	zoomLevel += _modifier; // 
	if (zoomLevel > MAX_ZOOM_LEVEL)		 {zoomLevel = MAX_ZOOM_LEVEL;}
	else if (zoomLevel < MIN_ZOOM_LEVEL) {zoomLevel = MIN_ZOOM_LEVEL;}
	sZoomLevel = string(1 / zoomLevel) + "x ";
	
	// 
	var _prevX		= camera_get_view_x(camera);
	var _prevY		= camera_get_view_y(camera);
	var _prevWidth	= camera_get_view_width(camera);
	var _prevHeight	= camera_get_view_height(camera);
	
	// 
	var _newWidth	= floor(WINDOW_WIDTH * zoomLevel);
	var _newHeight	= floor(WINDOW_HEIGHT * zoomLevel);
	camera_set_view_size(camera, _newWidth, _newHeight);
	
	// 
	camera_set_view_pos(camera,
		_prevX - ((_newWidth - _prevWidth) >> 1),
		_prevY - ((_newHeight - _prevHeight) >> 1)
	);
}

/// @description 
/// @param {Real}	inputLimit	Total number of characters that can be stored in "global.inputString" for the current text input.
process_text_input = function(_inputLimit){
	var _length = 0;
	with(global.inputText) {_length = string_length(text);}
	
	if (_length > 0){ // Only process attempts to backspace if there are characters to remove from the input string.
		if (keyboard_check(vk_backspace)){
			backspaceTimer -= deltaTime;
			if (backspaceTimer <= 0.0){
				if (IS_FIRST_BACKSPACE){ // First backspace waits slightly longer before triggering the faster speed.
					backspaceTimer =  FIRST_BSPACE_INTERVAL;
					flags		  &= ~FIRST_BACKSPACE;
				} else{ // Second backspace and onward uses the faster backspacing speed while held.
					backspaceTimer = NORM_BSPACE_INTERVAL;
				}
				
				// Update the currently visible input by removing the most recent character that was typed in
				// by the user.
				with(global.inputText){
					text = string_delete(text, _length, 1);
					keyboard_string	= "";
				}
			}
			return;
		} else{
			flags |= FIRST_BACKSPACE;
			backspaceTimer = 0.0;
		}
	}
	
	// Inputting a new character into the currently stored input text so long as the length of that text
	// doesn't currently exceed the limit allotted to the current input.
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

/// @description 
/// @param {Real}	startIndex	Starting index within the list of GUI buttons to enable/disable.
/// @param {Real}	count		Total number of GUI buttons to set to enabled/disabled.
/// @param {Bool}	enabled		The state to apply to the given region of GUI buttons.
set_buttons_enabled = function(_startIndex, _count, _enabled){
	var _length = ds_list_size(guiButtons);
	for (var i = 0; i < _count; i++){
		if (_startIndex + i > _length)
			return;
		with(guiButtons[| _startIndex + i]){
			if (_enabled)	{flags |=  BTN_ENABLED;}
			else			{flags &= ~BTN_ENABLED;}
		}
	}
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
		var _mDiffX = mStartPanX - (window_mouse_get_x() / WINDOW_SCALE * zoomLevel);
		var _mDiffY = mStartPanY - (window_mouse_get_y() / WINDOW_SCALE * zoomLevel);
		camera_set_view_pos(camera, _mDiffX, _mDiffY);
		return;
	}
	
	// 
	var _wheel = mouse_wheel_down() - mouse_wheel_up();
	if (_wheel != 0) {update_zoom_level(_wheel * 0.1);}
	
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
			if (_tileEmpty)	{create_map_tile(mouseCellX, mouseCellY, selectedBorder, selectedIcon);}
			else			{update_map_tile(_tileID, selectedBorder, selectedIcon);}
			update_tile_surface(_tileID);
			return;
		}
	
		// 
		if (!_tileEmpty && mouse_check_button(mb_right))
			delete_map_tile(_tileID);
		return;
	}

	// 
	if (mouse_check_button_released(mb_left)){
		if (_tileEmpty)	{create_map_tile(mouseCellX, mouseCellY, selectedBorder, selectedIcon);} 
		else			{update_map_tile(_tileID, selectedBorder, selectedIcon);}
		update_tile_surface(_tileID);
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
		if (mouse_check_button(mb_middle)){
			mStartPanX = mouse_x;
			mStartPanY = mouse_y;
		}
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
		var _prevMapWidth = global.mapWidth;
		with(global.inputText){
			text			= string_digits(text);
			if (text == "") {continue;}
			global.mapWidth = clamp(real(text), 1, 255);
			text			= "";
		}
		
		//
		if (_prevMapWidth == global.mapWidth){
			clear_selected_button();
			return;
		}
		
		// 
		if (_prevMapWidth > global.mapWidth)
			remove_out_of_bounds_tiles(global.mapWidth, 255);
		
		// 
		if (surface_exists(gridSurf)) {surface_free(gridSurf);}
		build_tile_surface(global.mapWidth, global.mapHeight);
		
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
		if (_prevMapHeight == global.mapHeight){
			clear_selected_button();
			return;
		}
		
		// 
		if (_prevMapHeight > global.mapHeight)
			remove_out_of_bounds_tiles(255, global.mapHeight);
		
		// 
		if (surface_exists(gridSurf)) {surface_free(gridSurf);}
		build_tile_surface(global.mapWidth, global.mapHeight);
		
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
	set_buttons_enabled(firstBorderIndex,	totalBorderIndexes, true);
	set_buttons_enabled(firstIconIndex,		totalIconIndexes,	false);
	set_buttons_enabled(firstDoorIndex,		MAX_DOORS_PER_TILE, false);
	nextState = lastState;
}

/// @description 
state_activate_icon_buttons = function(){
	set_buttons_enabled(firstIconIndex,		totalIconIndexes,	true);
	set_buttons_enabled(firstBorderIndex,	totalBorderIndexes, false);
	set_buttons_enabled(firstDoorIndex,		MAX_DOORS_PER_TILE, false);
	nextState = lastState;
}

/// @description 
state_activate_door_buttons = function(){
	set_buttons_enabled(firstDoorIndex,		MAX_DOORS_PER_TILE, true);
	set_buttons_enabled(firstIconIndex,		totalIconIndexes,	false);
	set_buttons_enabled(firstBorderIndex,	totalBorderIndexes, false);
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
ds_map_add(stateFunctions, STATE_ACTIVATE_DOORS,	state_activate_door_buttons);

// 
nextState = state_default;