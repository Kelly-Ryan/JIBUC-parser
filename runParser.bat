flex parser.l
bison -d parser.y
gcc -c lex.yy.c parser.tab.c
gcc -o parser lex.yy.o parser.tab.o
parser