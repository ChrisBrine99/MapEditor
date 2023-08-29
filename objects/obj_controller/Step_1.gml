// 
var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]){flags &= ~(BTN_HIGHLIGHTED);}
}

// 
mouseGuiX = window_mouse_get_x() * (GUI_WIDTH / window_get_width());
mouseGuiY = window_mouse_get_y() * (GUI_HEIGHT / window_get_height());