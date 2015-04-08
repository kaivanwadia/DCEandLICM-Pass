#!/bin/bash
clang -emit-llvm -c $1.c -o $1.bc
opt -mem2reg $1.bc -o $1.bc
make clean
if [ "$2" == "licm-pass" ]
then
	make $2
	opt -stats -loop-simplify -mergereturn -instnamer -load ./$2.so -$2 ./$1.bc -o ./$1_Opt.bc
elif [ "$2" == "dce-pass" ]
then
	make $2
	opt -stats -mergereturn -instnamer -load ./$2.so -$2 ./$1.bc -o ./$1_Opt.bc
else
	make
	opt -stats -loop-simplify -mergereturn -instnamer -load ./licm-pass.so -licm-pass ./$1.bc -o ./$1_Opt.bc
	opt -stats -mergereturn -instnamer -load ./dce-pass.so -dce-pass ./$1_Opt.bc -o ./$1_Opt.bc
fi
llvm-dis $1.bc -o $1.ll
llvm-dis $1_Opt.bc -o $1_Opt.ll