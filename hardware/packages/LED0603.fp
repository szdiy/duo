# author: Stefan Salewski
# email: mail@ssalewski.de
# dist-license: GPL
# use-license: unlimited

# LED SMD 0603
Element[0x00000000 "LED0603" "" "" 0 0 -6323 -10075 0 100 0x00000000]
(
	Pad[-3248 0 -3248 0 3150 2000 5150 "1" "1" 0x00000100]
	Pad[3248 0 3248 0 3150 2000 5150 "2" "2" 0x00000100]
	ElementLine [6323 3075 -6323 3075 1000]
	ElementLine [-6323 3075 -6323 -3075 1000]
	ElementLine [-6323 -3075 6323 -3075 1000]
	ElementLine [6323 -3075 6323 3075 1000]
	ElementLine [-173 -3075 -173 3075 1000]
)
