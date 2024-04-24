// 
draw_sprite_ext(spr_rectangle, 0, 0, 0, 100, GUI_HEIGHT, 0, c_black, 0.75);
draw_sprite_ext(spr_rectangle, 0, 100, 0, 1, GUI_HEIGHT - 13, 0, c_white, 1.0);
draw_sprite_ext(spr_rectangle, 0, 100, GUI_HEIGHT - 12, GUI_WIDTH, 12, 0, c_black, 0.75);
draw_sprite_ext(spr_rectangle, 0, 100, GUI_HEIGHT - 13, GUI_WIDTH - 100, 1, 0, c_white, 1.0);

// 
draw_sprite_ext(spr_rectangle, 0, 4, 81, 3 + ((TILE_WIDTH + ICON_SPACING) * ICONS_PER_ROW), 
	3 + ((TILE_HEIGHT + ICON_SPACING) * ICONS_PER_COLUMN), 0.0, c_dkgray, 0.65);
draw_sprite_ext(spr_rectangle, 0, 4, 221, 3 + ((TILE_WIDTH + ICON_SPACING) * ICONS_PER_ROW), 36, 0.0, c_dkgray, 0.65);

// 
draw_set_font(font_gui_small);
draw_set_halign(fa_right);
draw_set_color(c_gray);
draw_text(GUI_WIDTH - 2, GUI_HEIGHT - 9, 
	"Zoom " + sZoomLevel +
	"(" + string(mouse_x) + " [" + string(mouseCellX) + "], " +
		  string(mouse_y) + " [" + string(mouseCellY) + "])");

// 
draw_set_font(font_gui_medium);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(32, 225, "Final\nTile\nOutput");
draw_set_halign(fa_left);

// 
with(previewTileObject){
	image_xscale = 4.0;
	image_yscale = 4.0;
	image_alpha	 = 1.0;
	event_perform(ev_draw, 0);
}

// 
var _selectedButton = selectedButton;
var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++){
	with(guiButtons[| i]){
		// Skip over GUI buttons that are current disabled OR don't have a dedicated drawing function set.
		if (ID == _selectedButton || !IS_BTN_ENABLED || drawFunction == -1) 
			continue;
		
		// Execute the button's draw function, which can perform one of two different function calls. The first
		// is a simple "script_execute" call because there are no functions required by the function, and the
		// second requires the "drawArgs" argument to be passed into the function for its parameters; being 
		// called using "script_execute_ext".
		if (numDrawArgs == 0){
			script_execute(drawFunction);
			continue;
		}
		script_execute_ext(drawFunction, drawArgs);
	}
}

// 
with(_selectedButton){
	draw_sprite_ext(spr_rectangle, 0, 0, 0, GUI_WIDTH, GUI_HEIGHT, 0, c_black, 0.5);
	if (numDrawArgs == 0){
		script_execute(drawFunction);
		continue;
	}
	script_execute_ext(drawFunction, drawArgs);
}