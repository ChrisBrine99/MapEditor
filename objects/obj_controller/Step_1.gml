// 
var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]){flags &= ~(BTN_HIGHLIGHTED);}
}

// 
mouseGuiX = floor((mouse_x - camera_get_view_x(camera)) * (GUI_WIDTH / WINDOW_WIDTH));
mouseGuiY = floor((mouse_y - camera_get_view_y(camera)) * (GUI_HEIGHT / WINDOW_HEIGHT));