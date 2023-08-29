ds_map_destroy(stateFunctions);
ds_list_destroy(tileData);

var _length = ds_list_size(guiButtons);
for (var i = 0; i < _length; i++) {delete guiButtons[| i];}
ds_list_destroy(guiButtons);

camera_destroy(camera);

delete global.inputText;