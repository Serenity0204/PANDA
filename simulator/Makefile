CXX = g++
CXXFLAGS?=-Wall -Wmaybe-uninitialized -pedantic -Werror -g -O0 -std=c++17
OUTFILE = sim

all: $(OUTFILE)

$(OUTFILE): main.cpp Simulator.cpp Instruction.h Simulator.h
	$(CXX) $(CXXFLAGS) -o $(OUTFILE) main.cpp Simulator.cpp

clean:
	rm -f $(OUTFILE) *.o
