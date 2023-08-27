draw_sprite_ext(spr_rectangle, 0, 0, 0, 100, GUI_HEIGHT, 0, c_black, 0.75);
draw_sprite_ext(spr_rectangle, 0, 100, 0, 1, GUI_HEIGHT, 0, c_white, 1.0);

var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]){
		// TODO -- Add check to see if the button is enabled or not.
		if (drawFunction == -1) {continue;}
		
		// 
		if (numDrawArgs == 0){
			script_execute(drawFunction);
			continue;
		}
		script_execute_ext(drawFunction, drawArgs);
	}
}