var _video_data = video_draw();
var _video_status = _video_data[@ 0];

if (_video_status == 0) {
	var _surface = _video_data[@ 1];
	draw_surface(_surface, x, y);
}

var _subtitle = get_subtitle_text(); // retrieves the current line of dialogue from the .ass file

// draw the text however you like:

var _sep = 22;
var _w = 300;
var _padding = 4;

var _str_x = 160;
var _str_y = 200;
var _str_w = string_width_ext(_subtitle, _sep, _w);
var _str_h = string_height_ext(_subtitle, _sep, _w);

var _rect_x1 = (_str_x - (_str_w / 2) - _padding);
var _rect_x2 = (_str_x + (_str_w / 2) + _padding);
var _rect_y1 = (_str_y - (_str_h / 2) - _padding);
var _rect_y2 = (_str_y + (_str_h / 2) + _padding);

draw_set_alpha(0.5);
draw_set_color(#000000);

draw_roundrect_ext(_rect_x1, _rect_y1, _rect_x2, _rect_y2, 10, 10, false);

draw_set_alpha(1);
draw_set_color(#FFFFFF);

draw_set_font(fnt_arial);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text_ext(160, 200, _subtitle, 24, 300);