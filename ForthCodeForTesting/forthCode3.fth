: FACTORIAL ( n -- n! )
    DUP 1 DO DUP I * LOOP
;
10 FACTORIAL .
