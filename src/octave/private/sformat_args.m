function s = sformat_args(string, varargin)
	if (isempty(varargin))
		s = string;
	elseif (is_sq_string(string))
		s = sprintf(undo_string_escapes(string), varargin{:});
	else
		s = sprintf(string, varargin{:});
	endif
endfunction
