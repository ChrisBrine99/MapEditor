#region General Macros

// Store Window dimensions and scaling factor in macros so they can be easily auto-filled instead of having 
// to remember the values elsewhere in the code.
#macro	WINDOW_WIDTH			160
#macro	WINDOW_HEIGHT			120
#macro	WINDOW_SCALE			6

// 
#macro	GUI_WIDTH				320
#macro	GUI_HEIGHT				240

// 
#macro	TILE_WIDTH				8
#macro	TILE_HEIGHT				8

// 
#macro	BTN_CAN_SELECT			0x10000000
#macro	BTN_SELECTED			0x20000000
#macro	BTN_HIGHLIGHTED			0x40000000
#macro	BTN_ENABLED				0x80000000

// 
#macro	CAN_BTN_BE_SELECTED		(flags & BTN_CAN_SELECT)
#macro	IS_BTN_SELECTED			(flags & BTN_SELECTED)
#macro	IS_BTN_HIGHLIGHTED		(flags & BTN_HIGHLIGHTED)
#macro	IS_BTN_ENABLED			(flags & BTN_ENABLED)

#endregion

#region Global Variable Initializations

// 
global.mapName		= "Unnamed Map";
global.mapWidth		= 64;
global.mapHeight	= 64;
global.mapColor		= c_gray;

// 
global.inputText	= gui_button_create_text_struct(0, 0, "");

#endregion

#region Global Functions (GUI Buttons)

// GUI Button Utility Functions ///////////////////////////////////////////////////////////////////////////////////////

/// @description Creates a GUI Button struct, which is a region on the GUI layer of the screen that can be
/// hovered over and clicked on by the user to perform actions that are tied to the button through its "select
/// function".
/// @param {Real}		x				Position of the button in GUI layer pixels along the x axis.
/// @param {Real}		y				Position of the button in GUI layer pixels along the y axis.
/// @param {Real}		width			Size of the GUI button's bounding box along the x axis.
/// @param {Real}		height			Size of the GUI button's bounding box along the y axis.
/// @param {Real}		selectFunction	Function that is called whenever this GUI button has been clicked on by the user.
/// @param {String}		selectArgs		(Optional) Key value that points to the state function to set on obj_controller when the button is selected.
/// @param {Real}		drawFunction	(Optional) Index for function that will be used as the button's rendering function.
/// @param {Array<Any>}	drawArgs		(Optional) Arguments that will be utilized by the button's draw function.
/// @param {Real}		flags			(Optional) Allows manual setting of bit flags that alter the GUI Button's functionality.
function gui_button_create(_x, _y, _width, _height, _selectFunction, _selectArgs = [], _drawFunction = -1, _drawArgs = [], _flags = BTN_ENABLED | BTN_CAN_SELECT){
	var _sArgLen = array_length(_selectArgs);
	var _dArgLen = array_length(_drawArgs);
	var _button = {
		ID				:	noone,						// Stores the struct's "instance id" so it can pass itself to other objects for easy reference back to itself.
		flags			:	_flags,						// 32 unique bits that can alter the functionality of a GUI button.
		xPos			:	_x,							// Determines leftmost position of the button's clickable region.
		yPos			:	_y,							// Determines topmost position of the button's clickable region.
		width			:	_width,						// Stores width of the button's bounding box/clickable region.
		height			:	_height,					// Stores height of the button's bounding box/clickable region.
		selectFunction	:	_selectFunction,			// Function that is called when the button is clicked on by the user.
		selectArgs		:	array_create(_sArgLen, 0),	// Stores the key required to retrieve the desired pointer to an obj_controller state function.
		numSelectArgs	:	_sArgLen,					
		drawFunction	:	_drawFunction,				// Function that renders the button to the screen, which is completely optional.
		drawArgs		:	array_create(_dArgLen, 0),	// Contains arguments for the draw function's arguments; if it has any.
		numDrawArgs		:	_dArgLen,					// Stores total number of arguments required for the draw function.
	};
	array_copy(_button.selectArgs,	0, _selectArgs, 0, _sArgLen);
	array_copy(_button.drawArgs,	0, _drawArgs,	0, _dArgLen);
	_button.ID = _button; // Store unique identifying value much like how GML's id system works.
	return _button;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// GUI Button Selection Functions /////////////////////////////////////////////////////////////////////////////////////

/// @description 
/// @param {String}	functionKey		
function gui_button_select_general(_functionKey){
	with(obj_controller){
		var _value = ds_map_find_value(stateFunctions, _functionKey);
		if (!is_undefined(_value)){
			nextState		= _value;
			keyboard_string = "";
			return true;
		}
	}
	return false;
}

/// @description 
/// @param {String}				functionKey		
/// @param {Real}				xPos			
/// @param {Real}				yPos			
/// @param {Constant.HAlign}	hAlign			(Optional)
/// @param {Constant.VAlign}	vAlign			(Optional)
/// @param {Real}				color			(Optional)
function gui_button_select_general_has_input(_functionKey, _xPos, _yPos, _hAlign = fa_left, _vAlign = fa_top, _color = c_red){
	if (!gui_button_select_general(_functionKey)) {return;}
	
	// 
	with(global.inputText){
		x		= _xPos;
		y		= _yPos;
		hAlign	= _hAlign;
		vAlign	= _vAlign;
		color	= _color;
	}
}

/// @description 
/// @param {Real}	borderID	
function gui_button_select_map_borders(_borderID){
	with(obj_controller) {selectedBorder = _borderID;}
}

/// @description 
/// @param {Real}	iconID		
function gui_button_select_map_icons(_iconID){
	with(obj_controller) {selectedIcon = _iconID;}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// GUI Button Rendering Functions /////////////////////////////////////////////////////////////////////////////////////

/// @description Creates a generic "text" struct, which contains information that can/should be used to draw
/// the text onto the screen. It is primarily for GUI Buttons, but can also be used in other contexts if a
/// struct to manage a text's properties is required elsewhere.
/// @param {Real}				x		Position of the text along the x axis of the GUI layer.
/// @param {Real}				y		Position of the text along the y axis of the GUI layer.
/// @param {String}				text	String that will be rendered using the structs other properties.
/// @param {Constant.HAlign}	hAlign	(Optional) Horizontal alignment of the text relative to its x position.
/// @param {Constant.VAlign}	vAlign	(Optional) Vertical alignment of the text relative to its y position.
/// @param {Real}				color	(Optional) Color to be used when rendering the text onto the screen.
/// @param {Asset.GMFont}		font	(Optional) Font to be used when rendering the text onto the screen.
function gui_button_create_text_struct(_x, _y, _text, _hAlign = fa_left, _vAlign = fa_top, _color = c_white, _font = font_gui_small){
	return {
		x		: _x,
		y		: _y,
		text	: _text,
		hAlign	: _hAlign,
		vAlign	: _vAlign,
		color	: _color,
		font	: _font
	};
}

/// @description General function for rendering text to a GUI Button struct. It allows the user to set a font,
/// color, alignment. scaling, and opacity all in a single function call.
/// @param {Real}				x		Position along the x axis of the GUI layer to render the text at.
/// @param {Real}				y		Position along the y axis of the GUI layer to render the text at.
/// @param {String}				text	String of characters that will be rendered onto the GUI.
/// @param {Asset.GMFont}		font	The font resource that will be utilized for the text.
/// @param {Real}				color	The color to apply to the text that is rendered.
/// @param {Constant.HAlign}	hAlign	(Optional) Alignment relative to the position of the text along the x axis (Default is "fa_left").
/// @param {Constant.VAlign}	vAlign	(Optional) Alignment relative to the position of the text along the y axis (Default is "fa_top").
/// @param {Real}				scale	(Optional) Vertical and horizontal scaling that will be applied to the button's text (Default = 1.0).
/// @param {Real}				alpha	(Optional) Opacity value to render the text at (Ranging from 0.0 to 1.0).
function gui_button_draw_text(_x, _y, _text, _font, _color, _hAlign = fa_left, _vAlign = fa_top, _scale = 1.0, _alpha = 1.0){
	if (draw_get_font() != _font) {draw_set_font(_font);}
	draw_set_halign(_hAlign);
	draw_set_valign(_vAlign);
	draw_text_transformed_color(_x, _y, _text, _scale, _scale, 0, _color, _color, _color, _color, _alpha);
}

/// @description General function for rendering a background rectangle for the GUI Button, which is usually
/// set to the bounds of the button's clickable region, but it doesn't have to be. It takes in a "normal"
/// color as well as a "hover" color which allows rendering the background with different colors when the user
/// is hovering their mouse over the button and when they aren't.
/// @param {Real}	x			Position along the x axis of the GUI layer for the top-left position of the backing.
/// @param {Real}	y			Position along the y axis of the GUI layer for the top-left position of the backing.
/// @param {Real}	width		Size of the backing in pixels along the x axis.
/// @param {Real}	height		Size of the backing in pixels along the y axis.
/// @param {Real}	normColor	Default color to render the background with.
/// @param {Real}	hoverColor	Color to use for the background when the mouse is hovering over the button.
/// @param {Real}	alpha		Opacity value to render the background at (Ranging from 0.0 to 1.0).
function gui_button_draw_backing(_x, _y, _width, _height, _normColor, _hoverColor, _alpha){
	if (IS_BTN_HIGHLIGHTED) {draw_sprite_ext(spr_rectangle, 0, _x, _y, _width, _height, 0, _hoverColor, _alpha);}
	else					{draw_sprite_ext(spr_rectangle, 0, _x, _y, _width, _height, 0, _normColor, _alpha);}
}

/// @description General function for rendering an input area of a GUI Button, which is usually only shown when
/// the user has selected said button and it's taking input from the user via keyboard.
/// @param {Real}	x			Position of the input area's background rectangle along the x axis of the GUI layer.
/// @param {Real}	y			Position of the input area's background rectangle along the y axis of the GUI layer.
/// @param {Real}	width		Horizontal size of the background for the input area in GUI layer pixels.
/// @param {Real}	height		Vertical size of the background for the input area in GUI layer pixels.
/// @param {Struct}	helpText	Struct containing information relating to the help text that displays along side the current input string.
/// @param {Struct}	inputText	Struct containing information for rendering the current string of input text.
/// @param {Real}	backColor	Color utilized for the background of the input area.
/// @param {Real}	alpha		Opacity of the help text. Also affects overally opacity of background elements.
/// @param {Real}	backAlpha	Opacity of the background elements for the input dialog area.
function gui_button_draw_input_area(_x, _y, _width, _height, _helpText, _inputText, _backColor, _alpha, _backAlpha){
	// 
	draw_sprite_ext(spr_rectangle, 0, _x, _y, _width, _height, 0, _backColor, _alpha * _backAlpha);
	
	// Render the help and input text to the GUI; utilizing the general function for rendering text that is
	// normally used by GUI Buttons themselves, but can be used for other contexts qhen required.
	with(_helpText)		{gui_button_draw_text(x, y, text, font, color, hAlign, vAlign, 1, _alpha);}
	with(_inputText)	{gui_button_draw_text(x, y, text, font, color, hAlign, vAlign, 1, _alpha);}
}

/// @description 
/// @param {Struct}	drawnText	
/// @param {Struct} helpText	
function gui_button_draw_general(_drawnText, _helpText){
	gui_button_draw_backing(xPos, yPos, width, height, c_black, 0x404040, 0.65);
	if (!CAN_BTN_BE_SELECTED || !IS_BTN_SELECTED){ // Only render the current map name if a new one isn't being typed in by the user.
		with(_drawnText) {gui_button_draw_text(x, y, text, font, color, hAlign, vAlign);}
		return;
	}
	// 
	gui_button_draw_input_area(xPos, yPos - height, width, height * 2, 
		_helpText, global.inputText, 0x101010, 1, 0.75);
}

/// @description 
/// @param {Struct}	drawnText	
/// @param {Struct}	helpText	
/// @param {String}	dimension	Displays what the value to its right represents relative to the map's size; its width or height.
function gui_button_draw_map_dimension(_drawnText, _helpText, _dimension){
	gui_button_draw_general(_drawnText, _helpText);
	draw_set_halign(fa_left); 
	gui_button_draw_text(xPos + 3, yPos + 1, _dimension, font_gui_small, c_white);
}

/// @description 
/// @param {Asset.GMSprite}	sprite		
/// @param {Real}			imageIndex	
function gui_button_draw_tile_image(_sprite, _imageIndex){
	if (!IS_BTN_HIGHLIGHTED){
		draw_sprite_ext(spr_rectangle, 0, xPos, yPos, TILE_WIDTH, TILE_HEIGHT, 0, global.mapColor, 1);
		if (_sprite != -1 && _imageIndex != -1) {draw_sprite(_sprite, _imageIndex, xPos, yPos);}
		return;
	}
	draw_sprite_ext(spr_rectangle, 0, xPos, yPos, TILE_WIDTH, TILE_HEIGHT, 0, merge_color(global.mapColor, c_yellow, 0.5), 1);
	if (_sprite != -1 && _imageIndex != -1) {draw_sprite_ext(_sprite, _imageIndex, xPos, yPos, 1, 1, 0, c_yellow, 1);}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endregion 