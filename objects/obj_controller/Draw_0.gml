/*// Store the current position of the camera's viewport (The top-left position of the viewport relative to the 
// room's coordinates), as well as the width and height of that viewport (The bottom-left position of the 
// viewport relative to the room's coordinates) which are used throughout this Draw event.
var _cameraX = camera_get_view_x(camera);
var _cameraY = camera_get_view_y(camera);
var _cameraW = _cameraX + camera_get_view_width(camera);
var _cameraH = _cameraY + camera_get_view_height(camera);

// 
var _mapWidth	= global.mapWidth * TILE_WIDTH;
var _mapHeight	= global.mapHeight * TILE_HEIGHT;

// Determine the current position of the top-left and bottom-right of the viewport relative to the map surface's
// valid range of values. These will then be used to determine which portion of the surface to draw instead of
// having to waste time drawing the entire surface every frame, as the map grids can be fairly large.
var _startX = max(0, _cameraX);
var	_startY = max(0, _cameraY);
var _endX	= min(_mapWidth,	_cameraW);
var _endY	= min(_mapHeight, _cameraH);

// Make sure the surface that contains the map grid actually exists before drawing it. If not, it will be
// created to match the current width and height of the map in tiles that has been set by the user. After that,
// only the visible portion of the grid is drawn to the screen to save on rendering time.
if (!surface_exists(gridSurf)) {build_grid_surface(global.mapWidth, global.mapHeight, 0.75);}
draw_surface_part(gridSurf, _startX, _startY, _endX - _startX, _endY - _startY, _startX, _startY);

// If the tile surface needs to be updated, it will copy over what is currently in VRAM before clearing the
// flag that signals to the program that an update must occur to avoid any more copying between the CPU and
// GPU to happen as it is incredibly slow to do so.
if (CAN_UPDATE_SURF_BUFFER && surface_exists(tileSurf)){
	buffer_get_surface(tileSurfBuffer, tileSurf, 0);
	flags &= ~UPDATE_SURF_BUFFER;
}

// Finally, draw the tile surface to the screen, but on the currently visible area of said surface. If it was
// flushed from VRAM it will be reconstructed by copying whatever was stored in the buffer region for the
// surface that exists within system memory.
if (!surface_exists(tileSurf)){
	tileSurf = surface_create(global.mapWidth * TILE_WIDTH, global.mapHeight * TILE_HEIGHT);
	buffer_set_surface(tileSurfBuffer, tileSurf, 0);
}
draw_surface_part(tileSurf, _startX, _startY, _endX - _startX, _endY - _startY, _startX, _startY);

/// Drawing a translucent tile wherever the mouse is hovering over on the map. ///////////////////////////////////

// DOn't bother rendering the preview tile if the user's mouse is hovering over some part of the GUI.
if (IS_WITHIN_GUI) {return;}

// Store the mouse's current cell position within two temporary variables since they will be required for
// displaying the preview tile properly.
var _xCell = mouseCellX;
var _yCell = mouseCellY;

with(previewTileObject){
	// Store default position of the preview tile (Where it is on the GUI) into two temporary variables. After
	// that, the coordinates are shifted to the cell that the user's mouse is hovering over.
	var _tempX = x;
	var _tempY = y;
	
	x = _xCell * TILE_WIDTH;
	y = _yCell * TILE_HEIGHT;
	
	// Scale the image down to match the proper scaling for a map tile within the actual room while also
	// halving its opacity to make the grid/tile beneath it still visible to the user. Then, execute its
	// draw event to render the tile.
	image_xscale = 1.0;
	image_yscale = 1.0;
	image_alpha	 = 0.5;
	event_perform(ev_draw, 0);
	
	// Finally, reset its position back to where it was on the GUI (The scaling and alpha are set before the
	// tile is drawn again within the "Draw GUI" event of this controller object).
	x = _tempX;
	y = _tempY;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////