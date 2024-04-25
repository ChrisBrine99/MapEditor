// Don't bother trying to render a button that has its visibility flag set to zero. It can still be rendered if
// disabled should the "draw while inactive" flag is set.
if (!BTN_IS_VISIBLE || (!BTN_IS_ACTIVE && !BTN_DRAW_WHILE_INACTIVE))
	return;
	
// 
draw_sprite_stretched_ext(spr_button, 0, x, y, width, height, color, alpha);

// 
if (BTN_USES_SPRITE){
	
}

// 
if (!BTN_IS_TEXT_ENABLED)
	return;

// 
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(textFont);
draw_set_color(textColor);
draw_text(textX, textY, text);
draw_set_halign(fa_left);
draw_set_valign(fa_top);