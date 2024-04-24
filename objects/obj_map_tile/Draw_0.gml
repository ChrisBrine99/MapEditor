// 
draw_sprite_ext(spr_rectangle, 0, x, y, image_xscale * TILE_WIDTH, image_yscale * TILE_HEIGHT, 
	0.0, color, image_alpha);

// 
if (HAS_EASTERN_DOOR)	{draw_doorway(EASTERN_DOORWAY,	x + TILE_WIDTH - 1, y + 3);}
if (HAS_NORTHERN_DOOR)	{draw_doorway(NORTHERN_DOORWAY, x + 3, y);}
if (HAS_EASTERN_DOOR)	{draw_doorway(WESTERN_DOORWAY,	x, y + 3);}
if (HAS_EASTERN_DOOR)	{draw_doorway(SOUTHERN_DOORWAY,	x + 3, y + TILE_HEIGHT - 1);}

// 
if (border != -1)		{draw_sprite_ext(spr_map_borders, border, x, y, image_xscale, image_yscale, 0.0, c_white, image_alpha);}
if (icon != -1)			{draw_sprite_ext(spr_map_icons, icon, x, y, image_xscale, image_yscale, 0.0, c_white, image_alpha);}