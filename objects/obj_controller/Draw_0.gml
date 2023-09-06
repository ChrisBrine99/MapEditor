// Store the current position of the camera's viewport (The top-left position of the viewport relative to the 
// room's coordinates), as well as the width and height of that viewport (The bottom-left position of the 
// viewport relative to the room's coordinates) which are used throughout this Draw event.
var _cameraX = camera_get_view_x(camera);
var _cameraY = camera_get_view_y(camera);
var _cameraW = _cameraX + camera_get_view_width(camera);
var _cameraH = _cameraY + camera_get_view_height(camera);

// 
var _startX = max(0, _cameraX);
var	_startY = max(0, _cameraY);
var _endX	= min(global.mapWidth * TILE_WIDTH,	_cameraW);
var _endY	= min(global.mapHeight * TILE_HEIGHT, _cameraH);

// 
if (!surface_exists(gridSurf)) {build_grid_surface(global.mapWidth, global.mapHeight, 0.75);}
draw_surface_part(gridSurf, _startX, _startY, _endX - _startX, _endY - _startY, _startX, _startY);

// 
if (CAN_UPDATE_SURF_BUFFER && surface_exists(tileSurf)){
	buffer_get_surface(tileSurfBuffer, tileSurf, 0);
	flags &= ~UPDATE_SURF_BUFFER;
}

// 
if (!surface_exists(tileSurf)){
	tileSurf = surface_create(global.mapWidth * TILE_WIDTH, global.mapHeight * TILE_HEIGHT);
	buffer_set_surface(tileSurfBuffer, tileSurf, 0);
}
draw_surface_part(tileSurf, _startX, _startY, _endX - _startX, _endY - _startY, _startX, _startY);