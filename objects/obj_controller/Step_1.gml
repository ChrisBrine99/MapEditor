// 
var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]) {flags &= ~(BTN_HIGHLIGHTED);}
}

// 
mouseGuiX = window_mouse_get_x() * (GUI_WIDTH / window_get_width());
mouseGuiY = window_mouse_get_y() * (GUI_HEIGHT / window_get_height());

// 
mouseCellX = floor(mouse_x / TILE_WIDTH);
mouseCellY = floor(mouse_y / TILE_HEIGHT);

// 
if (IS_UPDATE_REQUIRED){
	bufferUpdateTimer -= deltaTime;
	if (bufferUpdateTimer < 0.0){
		flags &= ~UPDATE_REQUIRED;
		flags |= UPDATE_SURF_BUFFER;
		bufferUpdateTimer = 0.0;
	}
}

// 
if (keyboard_check(vk_control)){
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