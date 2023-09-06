// Draw the map tile's background first, which uses the color currently set for the map. After that, the
// border subimage for the tile is drawn, which represents the bounds of the area the tile represents.
draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 0, global.mapColor, 1);
if (border != -1) {draw_sprite(spr_map_borders, border, x, y);}

// Display the icon for the map tile if the tile in question has an icon attached to it. If it doesn't, 
// the value stored in "icon" will be -1 to signify there is no data to be represented for the tile.
if (icon != -1) {draw_sprite(spr_map_icons, icon, x, y);}