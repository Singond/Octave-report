## -*- texinfo -*-
## @deftypefn {Function File} {} ensure_dir_exists(@var{path})
##
## Ensure that the directory part of given path exists.
##
## The directory name is extracted by stripping all characters in @var{path}
## after the last directory separator.
## @end deftypefn
function ensure_dir_exists(path)
	[dir, name, ext] = fileparts(path);
	if (!isdir(dir))
		[status, msg, msgid] = mkdir(dir);
		if (status != 1)
			error("Could not create directory %s (error %d): %s",...
				dir, msgid, msg);
		endif
	endif
endfunction
