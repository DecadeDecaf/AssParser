function ass_parser_init() {
	global.sub_path = "";
	global.format_args = [];
	
	#macro start_time_arg "Start"
	#macro end_time_arg "End"
	#macro sub_text_arg "Text"
}

function timestamp_to_ms(_timestamp) {
	var _timer_hands = string_split(_timestamp, ":");
	var _timer_hand_hour = real(_timer_hands[@ 0]);
	var _timer_hand_minute = real(_timer_hands[@ 1]);
	var _timer_hand_second = real(_timer_hands[@ 2]);

	var _time_in_ms = 0;
	_time_in_ms += (_timer_hand_hour * 3600000);
	_time_in_ms += (_timer_hand_minute * 60000);
	_time_in_ms += (_timer_hand_second * 1000);
	
	return _time_in_ms;
}

function video_open_ext(_video, _sub = "") {
	video_open(_video);
	
	if (_sub == "") {
		_sub = filename_change_ext(_video, ".ass");
	}
	
	global.sub_path = _sub;
}

function get_subtitle_data() {
	var _filename = global.sub_path;
	var _file = file_text_open_read(_filename);
	
	var _format = [];
	var _parsed_ass = [];
	
	var _reached_events = false;
	var _reached_format = false;
	
	while (!file_text_eof(_file)) {
		var _ass_string = file_text_read_string(_file);
		
		if (!_reached_events) {
			if (_ass_string == "[Events]") {
				_reached_events = true;
			}
		} else if (!_reached_format) {
			if (string_starts_with(_ass_string, "Format: ")) {
				var _args_string = string_delete(_ass_string, 1, 8);
				var _args = string_split(_args_string, ", ", false);
				var _len = array_length(_args);
				global.format_args = _args;
				_reached_format = true;
			}
		} else if (string_starts_with(_ass_string, "Dialogue: ")) {
			var _args_string = string_delete(_ass_string, 1, 10);
			var _args_len = array_length(global.format_args);
			var _args = string_split(_args_string, ",", false, _args_len - 1);
			var _parsed_line = {};
			for (var _a = 0; _a < _args_len; _a++) {
				var _arg = _args[@ _a];
				struct_set(_parsed_line, global.format_args[@ _a], _arg);
			}
			array_push(_parsed_ass, _parsed_line);
		}
		
		file_text_readln(_file);
	}
	
	file_text_close(_file);
	
	return _parsed_ass;
}

function get_subtitle() {
	var _subs = get_subtitle_data();
	var _status = video_get_status();

	if (_status == video_status_playing) {
		var _current_timecode = (video_get_position());
		var _len = array_length(_subs);
		for (var _i = 0; _i < _len; _i++) {
			var _sub = _subs[@ _i];
			var _start_time = timestamp_to_ms(struct_get(_sub, start_time_arg));
			var _end_time = timestamp_to_ms(struct_get(_sub, end_time_arg));
			if (_current_timecode >= _start_time && _current_timecode <= _end_time) {
				return _sub;
			}
		}
	}
	
	return {};
}

function get_subtitle_info(_key) {
	var _sub = get_subtitle();
	
	if (struct_exists(_sub, _key)) {
		return struct_get(_sub, _key);
	}
	
	return "";
}

function get_subtitle_text() {
	return get_subtitle_info(sub_text_arg);
}