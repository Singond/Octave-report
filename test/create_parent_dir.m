addpath("../src/octave/private");

function test_create_parent(dirname, filename, contents)
	if (isdir(dirname))
		printf("Removing %s\n", dirname);
		rmdir(dirname);
	endif
	fullfilename = [dirname "/" filename];
	ensure_dir_exists(fullfilename);
	file = fopen(fullfilename, "w");
	fwrite(file, contents);
	fclose(file);
	printf("Successfully written %s\n", fullfilename);
endfunction

contents = "This file was written to a previously non-existent directory\n";
test_create_parent("test_non_existent_dir1", "file.txt", contents);
test_create_parent("test_non_existent_dir2/subdir", "file.txt", contents);
