: EGGSIZE
   DUP 18 < IF  ." reject "      ELSE
   DUP 21 < IF  ." small "       ELSE
   DUP 24 < IF  ." medium "      ELSE
   DUP 27 < IF  ." large "       ELSE
   DUP 30 < IF  ." extra large " ELSE
   ." error " 
   THEN THEN THEN THEN THEN DROP ;

19 EGGSIZE

