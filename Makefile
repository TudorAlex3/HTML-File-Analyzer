CC = g++
CFLAGS = -g
 
all: tema

tema:
	flex tema.l
	$(CC) -o tema lex.yy.c $(CFLAGS)

run1:
	./tema < 2.1.html

run2:
	./tema < 2.2.html

run3:
	./tema < 2.3.html

run4:
	./tema < 2.4.html

run5:
	./tema < 2.5.html

run6:
	./tema < 2.6.html

.PHONY : clean
clean :
	rm -f tema
	rm -f lex.yy.c
