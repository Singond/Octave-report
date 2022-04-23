function format_args(f, string, varargin)
	if (isempty(varargin))
		fputs(f, string);
	elseif (is_sq_string(string))
		fprintf(f, undo_string_escapes(string), varargin{:});
	else
		fprintf(f, string, varargin{:});
	endif
endfunction
