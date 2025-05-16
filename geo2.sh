#!/bin/bash

bison -o geo2.tab.c -d geo2.y 2> bison_errors.log
if [ $? -ne 0 ]; then
	cat bison_errors.log
	exit 1
fi
rm bison_errors.log

flex -o geo2.yy.c geo2.l 2> flex_errors.log
if [ $? -ne 0 ]; then
	cat flex_errors.log
	exit 1
fi
rm flex_errors.log

gcc -fsanitize=address -g -o geo2 geo2.tab.c geo2.yy.c src/*.c -Iinclude -lfl -lm 2> gcc_errors.log
if [ $? -ne 0 ]; then
	cat gcc_errors.log
	exit 1
fi
rm gcc_errors.log geo2.yy.c geo2.tab.c geo2.tab.h

if [ $# -eq 1 ]; then
	./geo2 $1
else 
	./geo2
fi