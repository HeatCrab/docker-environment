EXAMPLES := trafficlight hello counter adder

all clean format run:
	for dir in $(EXAMPLES); do \
		$(MAKE) -C $$dir $@; \
	done
