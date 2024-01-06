// 
if (IS_HIDDEN_AREA){
	draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 
		0.0, global.mapAuxColor, 1.0);
} else{
	draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 
		0.0, global.mapColor, 1.0);
}

// 
if (border != -1)	{draw_sprite(spr_map_borders, border, x, y);}
if (icon != -1)		{draw_sprite(spr_map_icons, icon, x, y);}