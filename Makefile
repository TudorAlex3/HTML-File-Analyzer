CC = g++
CFLAGS = -g
 
all: analyzer

analyzer:
	flex analyzer.l
	$(CC) -o analyzer lex.yy.c $(CFLAGS)

run1:
	./analyzer < 2.1.html

run2:
	./analyzer < 2.2.html

run3:
	./analyzer < 2.3.html

run4:
	./analyzer < 2.4.html

run5:
	./analyzer < 2.5.html

run6:
	./analyzer < 2.6.html

.PHONY : clean
clean :
	rm -f analyzer
	rm -f lex.yy.c
