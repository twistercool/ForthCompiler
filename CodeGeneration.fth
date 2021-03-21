32 CONSTANT BL 
: SPACES 0 DO SPACE LOOP ;
: FALSE 0 ;
: TRUE -1 ;
: TUCK SWAP OVER ;
: NIP SWAP DROP ;
: PRINTALL ( x0 x1 x2 ... xn --  )
    DEPTH 0 DO . LOOP 
;
: REVERSESTACK ( xn-1 xn-2 ... x1 x0 n -- x0 x1 ... xn-2 xn-1 )
    1 DO I ROLL LOOP 
;