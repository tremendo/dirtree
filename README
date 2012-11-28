Dir Tree

A little Ruby utility to print out an ASCII tree representation of a directory and its sub-directories and file contents.

Sample output:
	/wipes-and-dissolves/
	   /examples/
		  ./demo.html
		  ./test.html
	./README
	./wipes-and-dissolves.js

By default it will traverse the whole depth of every subdirectory under the starting directory.

A few options for filtering results or affecting the display.
-d limit depth/levels to given number of subdirectories
-g Display depth/level guides (vertical lines). Default off
	/wipes-and-dissolves/
	:  /examples/
	:  :  ./demo.html
	:  :  ./test.html
	./README
	./wipes-and-dissolves.js
-o only display directories, not individual files
	/wipes-and-dissolves/...
	   /examples/...
-f flat, full (relative) path of files as opposed to default tree-structure presentation
	/wipes-and-dissolves/
	/wipes-and-dissolves/examples/
	/wipes-and-dissolves/examples/demo.html
	/wipes-and-dissolves/examples/test.html
	/wipes-and-dissolves/README
	/wipes-and-dissolves/wipes-and-dissolves.js
-x REGEX exclude/ignore filenames matching given pattern
date YYYY-MM-DD[..[YYYY-MM-DD]] filter files to show only those modified within specified date range
	eg. dirtree date yesterday..  # list only files modified since the previous day

