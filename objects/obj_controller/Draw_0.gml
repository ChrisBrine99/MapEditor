// 
var _cameraX = camera_get_view_x(camera);
var _cameraY = camera_get_view_y(camera);

// 
var _startX = max(0, _cameraX);
var	_startY = max(0, _cameraY);
var _endX	= min(global.mapWidth * TILE_WIDTH,	_cameraX + WINDOW_WIDTH);
var _endY	= min(global.mapHeight * TILE_HEIGHT, _cameraY + WINDOW_HEIGHT);

// 
draw_sprite_stretched_ext(spr_rectangle, 0, _startX, _startY, _endX - _startX, _endY - _startY, c_black, 0.65);

// 
for (var yy = _startY - (_startY % TILE_HEIGHT); yy < _endY; yy += TILE_HEIGHT){
	for (var xx = _startX - (_startX % TILE_WIDTH); xx < _endX; xx += TILE_WIDTH){
		if (xx + TILE_WIDTH < _cameraX || xx - TILE_WIDTH > _cameraX + WINDOW_WIDTH ||
			yy + TILE_HEIGHT < _cameraY || yy - TILE_HEIGHT > _cameraY + WINDOW_HEIGHT)
				continue;
		draw_sprite(spr_map_borders, 0, xx, yy);
	}
}

// 
with(obj_map_tile){
	if (x + TILE_WIDTH < _cameraX || x - TILE_WIDTH > _cameraX + WINDOW_WIDTH ||
		y + TILE_HEIGHT < _cameraY || y - TILE_HEIGHT > _cameraY + WINDOW_HEIGHT)
			continue;
	
	draw_sprite_ext(spr_rectangle, 0, x, y, TILE_WIDTH, TILE_HEIGHT, 0, global.mapColor, 1);
	draw_sprite(spr_map_borders, image_index, x, y);
	
	// 
	if (icon == -1) {continue;}
	draw_sprite(spr_map_icons, icon, x + 2, y + 2);
}