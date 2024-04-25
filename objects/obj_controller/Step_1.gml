// First, grab what cell the mouse is currently hovering over within the map itself. This value is simply a
// conversion of the mouse's position within the "room" divided by a map tile's dimensions (8 by 8 pixels).
mouseCellX = floor(mouse_x / TILE_WIDTH);
mouseCellY = floor(mouse_y / TILE_HEIGHT);

// On top of determining the cell the mouse is occupying, grab the mouse's position on the GUI layer, which 
// has a resolution of 480 by 270; double that of the actual viewport's dimensions.
mouseGuiX = floor(window_mouse_get_x() * guiScaleRatioX);
mouseGuiY = floor(window_mouse_get_y() * guiScaleRatioY);


/*// Loop through all buttons and flip their "highlighted" flags to zero. This saves on having to determine if
// the mouse is actually still within the button's bounding box on each frame and instead just assumes no button
// is being highlighted.
var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]) {flags &= ~(BTN_HIGHLIGHTED);}
}

// Grab the mouse's position on the GUI layer, which has a resolution of 480 by 270; double that of the actual
// viewport's dimensions.
mouseGuiX = window_mouse_get_x() * (GUI_WIDTH / window_get_width());
mouseGuiY = window_mouse_get_y() * (GUI_HEIGHT / window_get_height());

// Also grab what cell the mouse is currently hovering over within the map itself. This value is simply a
// conversion of the mouse's position within the "room" divided by a map tile's dimensions (8 by 8 pixels).
mouseCellX = floor(mouse_x / TILE_WIDTH);
mouseCellY = floor(mouse_y / TILE_HEIGHT);

// Count down the timer for updating the surface's back up buffer that exists within system memory and not
// GPU memory. Once this timer reaches zero, all updates that have occurred to the surface will be copied
// over into this buffer in case it needs to be refreshed due to a GPU flush.
if (IS_UPDATE_REQUIRED){
	bufferUpdateTimer -= deltaTime;
	if (bufferUpdateTimer < 0.0){
		flags &= ~UPDATE_REQUIRED;
		flags |= UPDATE_SURF_BUFFER;
		bufferUpdateTimer = 0.0;
	}
}

// 
/*if (keyboard_check(vk_control)){
	if (keyboard_check_pressed(ord("Z"))){
		var _size = ds_list_size(undoCommands);
		if (_size == 0) {return;}
		
		var _command	= ds_list_find_value(undoCommands, _size - 1);
		var _args		= _command.args;
		if (array_length(_args) > 0) // Only bother using _ext function if there are arguments to parse.
			script_execute_ext(_command.func, _args);
		script_execute(_command.func);
		return;
	}
	
	if keyboard_check_pressed(ord("Y")){
		
	}
}