: FIZZBUZZ ( n -- ) \outputs fizzbuzz until n
    1+ 0 DO 
    I 15 MOD 0= IF ." FizzBuzz " CR
    ELSE I 5 MOD 0= IF ." Buzz " CR
    ELSE I 3 MOD 0= IF ." Fizz " CR
    ELSE I . CR
    THEN THEN THEN
    LOOP
;
100 FIZZBUZZ
