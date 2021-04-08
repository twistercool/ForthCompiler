VARIABLE NBTOCHECK
: ISPRIME ( n -- )
    NBTOCHECK !
    NBTOCHECK @ 2 < IF NBTOCHECK @ . ." IS NOT PRIME " 
    ELSE
        NBTOCHECK @ 2 = IF NBTOCHECK @ . ." IS PRIME " 
        ELSE 
            NBTOCHECK @ 2 DO
                NBTOCHECK @ 1- I = IF NBTOCHECK @ . ." IS PRIME " LEAVE 
                ELSE
                    NBTOCHECK @ I MOD 0= IF NBTOCHECK @ . ." IS NOT PRIME " LEAVE
                THEN THEN
            LOOP 
        THEN 
    THEN
;

: AREPRIME ( n -- )
    1+ 1 DO
        I ISPRIME CR
    LOOP
;

100 AREPRIME
