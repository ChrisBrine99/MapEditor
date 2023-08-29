// Store the current position of the camera's viewport (The top-left position of the viewport relative to the 
// room's coordinates), as well as the width and height of that viewport (The bottom-left position of the 
// viewport relative to the room's coordinates) which are used throughout this Draw event.
var _cameraX = camera_get_view_x(camera);
var _cameraY = camera_get_view_y(camera);
var _cameraW = _cameraX + WINDOW_WIDTH;
var _cameraH = _cameraY + WINDOW_HEIGHT;

// Determine where to start and where to end rendering the empty map tile subimages relative to the camera's
// viewport position and the dimensions of the current map: from (0, 0) to its width and height values (Stored
// in "global.mapWidth" and "global.mapHeight", respectively) multiplied by the tile's width and height.
var _startX = max(0, _cameraX);
var	_startY = max(0, _cameraY);
var _endX	= min(global.mapWidth * TILE_WIDTH,	_cameraW);
var _endY	= min(global.mapHeight * TILE_HEIGHT, _cameraH);

// Render the background of the editors available area for tiles within the currently visible region relative
// to the map's dimensions and the camera's position and viewport size. Then, render empty tile sprites on top
// of that background rectangle. Cells outside of the visible portion of the viewport aren't rendered.
draw_sprite_stretched_ext(spr_rectangle, 0, _startX, _startY, _endX - _startX, _endY - _startY, c_black, 0.65);
for (var yy = _startY - (_startY % TILE_HEIGHT); yy < _endY; yy += TILE_HEIGHT){
	for (var xx = _startX - (_startX % TILE_WIDTH); xx < _endX; xx += TILE_WIDTH)
		draw_sprite(spr_map_borders, 0, xx, yy);
}

// After rendering the map editor's area for tiles to be placed/deleted, the currently placed tiles themselves
// will attempt to render themselves; looping through them based on earliest ID to latest ID.
with(obj_map_tile){
	// Skip over the rendering for the map tile if its location is outside of the bounds of the camera.
	if (x + TILE_WIDTH < _cameraX || x - TILE_WIDTH > _cameraW ||
		y + TILE_HEIGHT < _cameraY || y - TILE_HEIGHT > _cameraH)
			continue;
	
	// Draw the map tile's background first, which uses the color currently set for the map. After that, the
	// border subimage for the tile is drawn, which represents the bounds of the area the tile represents.
	draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 0, global.mapColor, 1);
	if (border != -1) {draw_sprite(spr_map_borders, border, x, y);}
	
	// Display the icon for the map tile if the tile in question has an icon attached to it. If it doesn't, 
	// the value stored in "icon" will be -1 to signify there is no data to be represented for the tile.
	if (icon == -1) {continue;}
	draw_sprite(spr_map_icons, icon, x, y);
}