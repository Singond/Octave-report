## Ensure a directory does not exist
function dirname = non_existent_dir(dirname)
	if (nargin < 1)
		dirname = "test_newdir";
	endif
	if (isdir(dirname))
		printf("Removing %s\n", dirname);
		confirm_recursive_rmdir(false, "local");
		[st, msg, id] = rmdir(dirname, "s");
		if (st != 1)
			error("[%s] Could not remove directory %s: %s\n", id, dirname, msg);
		endif
	endif
endfunction