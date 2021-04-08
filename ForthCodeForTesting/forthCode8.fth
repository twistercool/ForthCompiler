\ 10000 0 DO I 5 MOD 0 = IF 0 . ELSE 1 . THEN LOOP

\ 3 4 5 61 2 4 5 1 3 5 DEPTH 0 DO DEPTH 0 DO DUP ROT  LOOP LOOP 
: BUBBLE ( a1 ... an n-1 -- one pass )
    DUP IF >R
    OVER OVER < IF SWAP THEN
    R> SWAP >R 1-  R> 
    1-  R> 
    R> SWAP >R 1-  R> 
    ELSE 
        DROP 
    THEN 
;

: SORT ( a1 .. an n -- sorted  )
    1- DUP 0 DO >R R@ BUBBLE R> LOOP DROP 
;

2 4 2 7 4 SORT
