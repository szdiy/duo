PCB=pcb
FILEBASE=duo
BOMFILE=${FILEBASE}.bom.txt
XYFILE=${FILEBASE}.xy.txt

default: gerber

gerber:
	${PCB} -x gerber --gerberfile ${FILEBASE} ${FILEBASE}.pcb
	mv *.gbr *.cnc ./duo-gerber

# backend bom and bom2 need a file "attribs" in the local folder
bom:
	#gnetlist -g partslist3 -o duo.bom duo.sch
	#gnetlist -g partslist1 -o duo.bom duo.sch
	#gnetlist -g bom -o duo.bom duo.sch
	gnetlist -g bom2 -o duo.bom duo.sch

bom-sensorbrd:
	gnetlist -g bom2 -o sensor-board.bom sensor-board.sch

pcb:
	gsch2pcb --use-files --elements-dir ~/footprints duo.sch

pdf: duo.pdf

%.pdf: %.ps
	ps2pdf $< $@

%.ps: %.sch
	gschem -p -o $@ -s /usr/local/share/gEDA/scheme/print.scm $<

# use the following command to generate colored ps file
# gschem -p -o duo.ps -s /usr/share/gEDA/scheme/print.scm duo.sch

# ps to png workflow
# ps --(ps2epsi)--> epsi --(eps2png)--> png
#
png: duo.epsi
	./eps2png -width 1800 duo.epsi

drc:
	gnetlist -g drc2 -o - duo.sch

clean:
	rm -f *.gbr *.bom *.cnc *.pdf ${BOMFILE} ${XYFILE}

