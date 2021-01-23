\ 221 220 > IF 34 . ELSE 23 . THEN 54355 .
\ 11 1 DO I 5 < IF 20 . THEN LOOP
\ : DAB 5 1 DO 10 6 DO 15 11 DO 20 16 DO i . LOOP LOOP LOOP LOOP ;
\ 5 1 do DAB loop

: QUADRATIC  ( a b c x -- n )   >R SWAP ROT R@ *  + R> *  + ;
2 7 9 3 quadratic . 