#region General Macros

// Store Window dimensions and scaling factor in macros so they can be easily auto-filled instead of having 
// to remember the values elsewhere in the code.
#macro	WINDOW_WIDTH			160
#macro	WINDOW_HEIGHT			90
#macro	WINDOW_SCALE			6

// 
#macro	GUI_WIDTH				320
#macro	GUI_HEIGHT				180

// 
#macro	TILE_WIDTH				8
#macro	TILE_HEIGHT				8

// 
#macro	BTN_FLAG0				0x00000001
#macro	BTN_SELECTED			0x20000000
#macro	BTN_HIGHLIGHTED			0x40000000
#macro	BTN_ENABLED				0x80000000

// 
#macro	BTN_FLAG0_SET			(flags & BTN_FLAG0)
#macro	IS_BTN_SELECTED			(flags & BTN_SELECTED)
#macro	IS_BTN_HIGHLIGHTED		(flags & BTN_HIGHLIGHTED)
#macro	IS_BTN_ENABLED			(flags & BTN_ENABLED)

#endregion

#region Global Variable Initializations

// 
global.mapName		= "Unnamed Map";
global.mapColor		= c_gray;
global.mapWidth		= 32;
global.mapHeight	= 32;

// 
global.inputString	= "";

#endregion

#region Global Functions (GUI Buttons)

/// GUI Button Utility Functions //////////////////////////////////////////////////////////////////////////////////////

/// @description 
/// @param {Real}		x				Position of the button in GUI layer pixels along the x axis.
/// @param {Real}		y				Position of the button in GUI layer pixels along the y axis.
/// @param {Real}		width			Size of the GUI button's bounding box along the x axis.
/// @param {Real}		height			Size of the GUI button's bounding box along the y axis.
/// @param {Real}		selectFunction	Function that is called whenever this GUI button has been clicked on by the user.
/// @param {Real}		drawFunction	(Optional) Index for function that will be used as the button's rendering function.
/// @param {Array<Any>}	drawArgs		(Optional) Arguments that will be utilized by the button's draw function.
function gui_button_create(_x, _y, _width, _height, _selectFunction, _drawFunction = -1, _drawArgs = []){
	var _length = array_length(_drawArgs);
	var _button = {
		ID				:	noone,
		flags			:	BTN_ENABLED,
		xPos			:	_x,
		yPos			:	_y,
		width			:	_width,
		height			:	_height,
		selectFunction	:	_selectFunction,
		drawFunction	:	_drawFunction,
		drawArgs		:	array_create(_length, 0),
		numDrawArgs		:	_length,
	};
	array_copy(_button.drawArgs, 0, _drawArgs, 0, _length);
	_button.ID = _button;
	return _button;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// GUI Button Selection Functions ////////////////////////////////////////////////////////////////////////////////////

/// @description 
function gui_button_select_map_name(){
	var _buttonID = ID;
	with(obj_controller){
		nextState		= state_input_map_name;
		selectedButton	= _buttonID;
	}
	flags |= BTN_SELECTED;
	keyboard_string = "";
}

/// @description 
function gui_button_select_map_width(){
	var _buttonID = ID;
	with(obj_controller){
		nextState		= state_input_map_width;
		selectedButton	= _buttonID;
	}
	flags |= BTN_SELECTED;
	keyboard_string = "";
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// GUI Button Rendering Functions ////////////////////////////////////////////////////////////////////////////////////

/// @description 
/// @param {Real}				x		Position along the x axis of the GUI layer to render the text at.
/// @param {Real}				y		Position along the y axis of the GUI layer to render the text at.
/// @param {String}				text	String of characters that will be rendered onto the GUI.
/// @param {Asset.GMFont}		font	The font resource that will be utilized for the text.
/// @param {Real}				color	The color to apply to the text that is rendered.
/// @param {Constant.HAlign}	hAlign	(Optional)	Alignment relative to the position of the text along the x axis (Default is "fa_left").
/// @param {Constant.VAlign}	vAlign	(Optional)	Alignment relative to the position of the text along the y axis (Default is "fa_top").
/// @param {Real}				scale	(Optional)	Vertical and horizontal scaling that will be applied to the button's text (Default = 1.0).
/// @param {Real}				alpha	(Optional)	Opacity value to render the text at (Ranging from 0.0 to 1.0).
function gui_button_draw_text(_x, _y, _text, _font, _color, _hAlign = fa_left, _vAlign = fa_top, _scale = 1.0, _alpha = 1.0){
	if (draw_get_font() != _font) {draw_set_font(_font);}
	draw_set_halign(_hAlign);
	draw_set_valign(_vAlign);
	draw_text_transformed_color(_x, _y, _text, _scale, _scale, 0, _color, _color, _color, _color, _alpha);
}

/// @description 
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

/// @description 
/// @param {Real}				x			
/// @param {Real}				y			
/// @param {Real}				width		
/// @param {Real}				height		
/// @param {Struct}				helpText	Struct containing information relating to the help text that displays along side the current input string.
/// @param {Struct}				inputText	Struct containing information for rendering the current string of input text.
/// @param {Real}				backColor	Color utilized for the background of the input area.
/// @param {Real}				alpha		Opacity of the help text. Also affects overally opacity of background elements.
/// @param {Real}				backAlpha	Opacity of the background elements for the input dialog area.
function gui_button_draw_input_area(_x, _y, _width, _height, _helpText, _inputText, _backColor, _alpha, _backAlpha){
	// 
	draw_sprite_ext(spr_rectangle, 0, 0, 0, GUI_WIDTH, GUI_HEIGHT, 0, c_black, _alpha * _backAlpha);
	draw_sprite_ext(spr_rectangle, 0, _x, _y, _width, _height, 0, _backColor, _alpha * _backAlpha);
	
	// 
	with(_helpText)		{gui_button_draw_text(x, y, text, font, color, hAlign, vAlign, 1, _alpha);}
	with(_inputText)	{gui_button_draw_text(x, y, text, font, color, hAlign, vAlign, 1, _alpha);}
	delete _helpText;	// 
	delete _inputText;
}

/// @description 
/// @param {Real}				x
/// @param {Real}				y
/// @param {String}				text
/// @param {Constant.HAlign}	hAlign
/// @param {Constant.VAlign}	vAlign
/// @param {Real}				color
/// @param {Asset.GMFont}		font
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

/// @description 
function gui_button_draw_map_name(){
	// 
	gui_button_draw_backing(xPos, yPos, width, height, c_black, 0x404040, 0.65);
	if (!IS_BTN_SELECTED){ // Only render the current map name if a new one isn't being typed in by the user.
		gui_button_draw_text(xPos + 3, yPos + 1, global.mapName, font_gui_small, c_red);
		return;
	}
	
	// 
	gui_button_draw_input_area(
		xPos, yPos - height, width, height * 2, 
		gui_button_create_text_struct(xPos + (width >> 1), yPos - 9, "Enter Name Below", fa_center),
		gui_button_create_text_struct(xPos + 3, yPos + 1, global.inputString, fa_left, fa_top, c_red),
		0x101010, 1, 0.75
	);
}

/// @description 
function gui_button_draw_map_width(){
	gui_button_draw_backing(xPos, yPos, width, height, c_black, 0x404040, 0.65);
	gui_button_draw_text(xPos + 3, yPos + 1, "Width", font_gui_small, c_white);
	if (!IS_BTN_SELECTED){
		gui_button_draw_text(xPos + width - 3, yPos + 1, string(global.mapWidth), font_gui_small, c_yellow, fa_right);
		draw_set_halign(fa_left);
		return;
	}
	
	// 
	gui_button_draw_input_area(
		xPos, yPos - height, width, height * 2, 
		gui_button_create_text_struct(xPos + (width >> 1), yPos - 9, "Enter Value (1 - 255)", fa_center),
		gui_button_create_text_struct(xPos + width - 3, yPos + 1, global.inputString, fa_right, fa_top, c_yellow),
		0x101010, 1, 0.75
	);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endregion 