VARIABLE DATA
VARIABLE NB
4 NB ! 12 DATA !
DATA @ . NB @ . 543 NB ! NB @ .

20 CONSTANT TWENTY

0 CONSTANT REJECT
1 CONSTANT SMALL
2 CONSTANT MEDIUM
3 CONSTANT LARGE
4 CONSTANT EXTRA-LARGE
5 CONSTANT ERROR

: CATEGORY ( weight -- category )
   DUP 18 < IF   REJECT      ELSE
   DUP 21 < IF   SMALL       ELSE
   DUP 24 < IF   MEDIUM      ELSE
   DUP 27 < IF   LARGE       ELSE
   DUP 30 < IF   EXTRA-LARGE ELSE
   ERROR
   THEN THEN THEN THEN THEN  NIP ;

TWENTY . 
TWENTY .
TWENTY . 
TWENTY 
TWENTY . .
5 SPACES

23 CATEGORY .