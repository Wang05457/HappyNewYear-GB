build:
	rgbasm -L -o NewYear.o NewYear.asm
	rgblink -o NewYear.gb NewYear.o
	rgbfix -v -p 0xFF NewYear.gb

clean:
	rm -f NewYear.o
	rm -f NewYear.gb

