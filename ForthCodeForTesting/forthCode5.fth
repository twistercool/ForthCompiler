
: QUADRATIC  ( a b c x -- n )   >R SWAP ROT R@ *  + R> *  + ;
2 7 9 3 quadratic .

: STAR	 ( -- )            \ Print a single star
[CHAR] * EMIT ;	           \ 42 is the ASCII code for *


: STARS	( n -- )   \ Print n stars
0 DO STAR LOOP ;	   \ Loop n times (0 up to n-1) and execute STAR


: SQUARESTARS	( n -- )   \ Print an n-line square of stars
DUP 0 DO		   \ Loop n times, keeping (DUP-licating) n on the stack
DUP STARS CR            \ Each time, print n stars then print CR
LOOP DROP ;             \ After loop is done, drop the n from the stack


: TRIANGLE	( n -- )   \ Print an n-line triangle
1 + 1 DO		   \ Loop n times from 1 to n (instead of 0 to n-1)
I STARS CR              \ This time use the inner loop index I
LOOP ;


: TOWER	( n -- )   \ Print a "tower" with an base of size n
DUP                     \ DUP-licate n (since it is used twice below)
1 - TRIANGLE            \ Print a triangle 1 size smaller than n
SQUARESTARS ;                \ Print a square base of size n


CR 6 TOWER