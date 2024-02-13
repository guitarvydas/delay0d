LIBSRC=0D/odin/std
ODIN_FLAGS ?= -debug -o:none
D2J=0d/das2json/das2json

run: delay0d transpile.drawio.json
	@echo
	./delay0d 'hello from delay example' main delay0d.drawio $(LIBSRC)/transpile.drawio

delay0d: delay0d.drawio.json
	odin build . $(ODIN_FLAGS)

delay0d.drawio.json: delay0d.drawio transpile.drawio.json
	$(D2J) delay0d.drawio

transpile.drawio.json: $(LIBSRC)/transpile.drawio
	$(D2J) $(LIBSRC)/transpile.drawio

clean:
	rm -rf delay0d delay0d.dSYM *~ *.json
