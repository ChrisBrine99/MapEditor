// Create the camera, set its viewport size, assign it to viewport 0, and enable the rendering of active viewports.
camera = camera_create();
camera_set_view_size(camera, WINDOW_WIDTH, WINDOW_HEIGHT);
camera_set_view_pos(camera, -54, -4);
view_set_camera(0, camera);
view_set_visible(0, true);
view_enabled = true;

// Ensure the GUI layer and the application surface both have a resolution that matches the viewport's dimensions.
display_set_gui_size(GUI_WIDTH, GUI_HEIGHT);
surface_resize(application_surface, WINDOW_WIDTH, WINDOW_HEIGHT);

// Scale and resize the program window. On top of that, center it on the primary display.
var _windowWidth	= WINDOW_WIDTH * WINDOW_SCALE;
var _windowHeight	= WINDOW_HEIGHT * WINDOW_SCALE;
window_set_position((display_get_width() - _windowWidth) >> 1, (display_get_height() - _windowHeight) >> 1);
window_set_size(_windowWidth, _windowHeight);