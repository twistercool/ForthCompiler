32 CONSTANT BL 
: SPACES ( x0 --  )
    0 DO SPACE LOOP 
;
: FALSE (  --  0 ) 0 ;
: TRUE (  --  -1 ) -1 ;
: TUCK ( x0 x1 -- x1 x0 x1 ) 
    SWAP OVER
;
: NIP ( x0 x1 -- x1 )
    SWAP DROP 
;
: PRINTALL ( x0 x1 x2 ... xn --  )
    DEPTH 0 DO . LOOP 
;
: REVERSESTACK ( xn-1 xn-2 ... x1 x0 n -- x0 x1 ... xn-2 xn-1 )
    1 DO I ROLL LOOP 
;
: ISFACTOR ( f n -- x )
    MOD 0=
;
: SQUARE ( x -- x^2 )
    DUP *
;
: 2DUP ( x0 x1-- x0 x1 x0 x1)
    OVER OVER    
;