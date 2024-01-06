ds_map_destroy(stateFunctions);
//ds_list_destroy(redoCommands);
ds_list_destroy(tileData);
camera_destroy(camera);

var _length = ds_list_size(undoCommands);
for (var i = 0; i < _length; i++) {delete undoCommands[| i];}
ds_list_destroy(undoCommands);

_length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++) {delete guiButtons[| i];}
ds_list_destroy(guiButtons);

var _key = ds_map_find_first(global.textStructs);
while(!is_undefined(_key)){
	ds_map_delete(global.textStructs, _key);
	_key = ds_map_find_next(global.textStructs, _key);
}
ds_map_destroy(global.textStructs);