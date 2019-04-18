function writelatexvars(file, V)
	% Get file handle
	if (ischar(file))
		f = fopen(file, "w");
		fprivate = 1;
	elseif (is_valid_file_id(file))
		% 'f' is a file handle
		f = file;
		fprivate = 0;
	else
		error(["Bad 'file' argument. Expecting file name or handle, got ", ...
				typeinfo(file)]);
	endif

	if (isstruct(V))
		if (length(V) > 1)
			error(["The input must be a scalar structure, " ...
					"not a structure array"]);
		endif
		% Input is key-value pairs
		for [val, name] = V;
			% TODO Handle different types
			if (isinteger(val))
				valstr = sprintf("%d", val);
			else
				valstr = sprintf("%f", val);
			endif
			fprintf(f, '\\newcommand\\%s{%s}\n', name, valstr);
		endfor
	endif

	% Clean up if the file was created in this function
	if (fprivate)
		fclose(f);
	endif
endfunction
