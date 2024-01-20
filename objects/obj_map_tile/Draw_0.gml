// 
draw_sprite_ext(spr_rectangle, 0, x, y, image_xscale * TILE_WIDTH, image_yscale * TILE_HEIGHT, 
	0.0, color, image_alpha);

// 
if (border != -1)	{draw_sprite_ext(spr_map_borders, border, x, y, image_xscale, image_yscale, 0.0, c_white, image_alpha);}
if (icon != -1)		{draw_sprite_ext(spr_map_icons, icon, x, y, image_xscale, image_yscale, 0.0, c_white, image_alpha);}