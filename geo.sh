#!/bin/bash

bison -o geo.tab.c -d geo.y 2> bison_errors.log
if [ $? -ne 0 ]; then
	cat bison_errors.log
	exit 1
fi
rm bison_errors.log

flex -o geo.yy.c geo.l 2> flex_errors.log
if [ $? -ne 0 ]; then
	cat flex_errors.log
	exit 1
fi
rm flex_errors.log

gcc -fsanitize=address -g -o geo geo.tab.c geo.yy.c src/*.c -Iinclude -lfl -lm 2> gcc_errors.log
if [ $? -ne 0 ]; then
	cat gcc_errors.log
	exit 1
fi
rm gcc_errors.log geo.yy.c geo.tab.c geo.tab.h

if [ $# -eq 1 ]; then
	./geo $1
else 
	./geo
fi