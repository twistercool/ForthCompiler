: FIB ( x0 x1 - x0 x1 x0+x1 ) 
    OVER OVER + 
;
: FIBS ( n -- fib_0 fib_1 fib_2 ... fib_n )
    0 1 ROT 2 DO FIB LOOP 
;
40 FIBS PRINTALL