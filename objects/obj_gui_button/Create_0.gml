#region Macro Initialization

// ------------------------------------------------------------------------------------------------------- //
//	Macro representation of the bits that are utilized as flags to enable/disable various parts of the	   //
//	GUI button that aren't reliant on a single state function.											   //
// ------------------------------------------------------------------------------------------------------- //

#macro	BTN_SPRITE				0x01000000
#macro	BTN_TEXT				0x02000000
#macro	BTN_LOCKED_SIZE			0x04000000
#macro	BTN_HIGHLIGHTING		0x08000000
#macro	BTN_SELECTING			0x10000000
#macro	BTN_DRAW_INACTIVE		0x20000000
#macro	BTN_VISIBLE				0x40000000
#macro	BTN_ACTIVE				0x80000000

// ------------------------------------------------------------------------------------------------------- //
//	Macros for condensing the typing required to check any of a given GUI button's current flags.		   //
// ------------------------------------------------------------------------------------------------------- //

#macro	BTN_USES_SPRITE			(flags & BTN_SPRITE)
#macro	BTN_IS_TEXT_ENABLED		(flags & BTN_TEXT)
#macro	BTN_HAS_LOCKED_SIZE		(flags & BTN_LOCKED_SIZE)
#macro	BTN_CAN_HIGHLIGHT		(flags & BTN_HIGHLIGHTING)
#macro	BTN_CAN_SELECT			(flags & BTN_SELECTING)
#macro	BTN_DRAW_WHILE_INACTIVE	(flags & BTN_DRAW_INACTIVE)
#macro	BTN_IS_VISIBLE			(flags & BTN_VISIBLE)
#macro	BTN_IS_ACTIVE			(flags & BTN_ACTIVE)

#endregion

#region Local Variable Initialization

// 
curState		= NO_FUNCTION;
nextState		= NO_FUNCTION;
lastState		= NO_FUNCTION;
flags			= 0;

// 
spriteIndex		= NO_SPRITE;
imageIndex		= 0;
spriteX			= 0;
spriteY			= 0;

// 
text			= "";
textX			= 0;
textY			= 0;
textPadding		= 0;
textWidth		= 0;
textHeight		= 0;
textColor		= c_white;
textFont		= font_gui_small;

// 
width			= 0;
height			= 0;
preferredWidth	= 0;
preferredHeight = 0;

// 
color			= c_white;
alpha			= 1.0;

#endregion

#region Function Initialization

/// @description 
/// @param {Function}	state	What function the button should be executing during their step event by default.
/// @param {Real}		width	How wide the button is in whole GUI pixels.
/// @param {Real}		height	How tall the button is in whole GUI pixels.
/// @param {Real}		color	The desired color of the button when not highlighted/selected (If those functionalities are enabled).
/// @param {Real}		alpha	How visible the button itself should be (Doesn't effect text/sprite elements).
/// @param {Real}		flags	Determines what general functionalities are enabled/disabled upon creation.
initialize_general = function(_state, _width, _height, _color, _alpha, _flags){
	nextState		= _state;
	width			= _width;
	height			= _height;
	preferredWidth	= _width;
	preferredHeight = _height;
	color			= _color;
	alpha			= _alpha;
	flags			= _flags;
}

/// @description 
/// @param {String}			text		The string of text that will displayed on the button.
/// @param {Real}			padding		How many pixels there should be between the text and the edges of the button.
/// @param {Real}			color		Determines what color the text should be rendered with.
/// @param {Asset.GMFont}	font		The font to use when drawing the button's text.
initialize_text = function(_text, _padding, _color, _font){
	// Don't bother adding text data to the button if the flag for enabling text wasn't set.
	if (!BTN_IS_TEXT_ENABLED)
		return;
	
	// 
	textPadding	= _padding;
	textColor	= _color;
	textFont	= _font;
	
	// 
	draw_set_font(_font);
	if (BTN_HAS_LOCKED_SIZE){
		textX	= x + floor(width / 2);
		textY	= y + floor(height / 2);
		
		// 
		var _newString	= "";
		var _char		= "";
		var _xPos		= 0;
		var _yPos		= string_height("M") / 2;
		var _fullPad	= textPadding * 2;
		var _length		= string_length(_text);
		for (var i = 1; i <= _length; i++){
			_char	= string_char_at(_text, i);
			
			// 
			if (_char == "\n"){
				_xPos	= 0;
				_yPos  += string_height(_char);
				if (_yPos + _fullPad > height)
					break;
				
				text += _char;
				continue;
			}
			
			// 
			if (_char == " " || _xPos + _fullPad > width){
				_xPos	= 0;
				_yPos  += string_height(_char);
				if (_yPos + _fullPad > height)
					break;
				
				text   += "\n";
				continue;
			}
			
			// The space can fit on the current line; add it to the displayed text and continue.
			text   += _char;
			_xPos  += string_width(_char);
		}
		
		return;
	}
	
	// The text's width and height can override what was set up as the preferred width and height of the
	// button through its general initialization function, so the width and height can be set without much
	// processing to determine how much text can fit on the button (As is required in the code above).
	text		= _text;
	textWidth	= string_width(_text);
	textHeight	= string_height(_text);
	
	// Update the width and height variables if the text dimensions alongside their padding happen to exceed
	// what the button had set as its preferred width and height.
	var _fullPad = textPadding * 2;
	if (textWidth + _fullPad > preferredWidth)
		width	= textWidth + _fullPad + 2;
	if (textHeight + _fullPad > preferredHeight)
		height	= textHeight + _fullPad + 2;
	
	// Finally, determine the center of the button so the text can be aligned perfectly within the button's
	// dimensions (Padding included).
	textX = x + floor(width / 2);
	textY = y + floor(height / 2);
}

#endregion