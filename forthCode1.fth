\ hello world program in forth	
CR
: STAR 42 EMIT ;
: STARS 0 DO STAR LOOP ;
: F 5 STARS CR STAR CR 5 STARS CR STAR CR STAR CR STAR ;
CR F CR
