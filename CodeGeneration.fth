32 CONSTANT BL 
: SPACES ( x0 --  ) 0 DO SPACE LOOP ;
: FALSE (  --  0 ) 0 ;
: TRUE (  --  -1 ) -1 ;
: -ROT ( x0 x1 x2 -- x2 xx0 x1 ) ROT ROT ;
: TUCK ( x0 x1 -- x1 x0 x1 ) SWAP OVER ;
: NIP ( x0 x1 -- x1 ) SWAP DROP ;
: PRINTALL ( x0 x1 x2 ... xn --  ) DEPTH 0 DO . LOOP ;
: CLEARSTACK ( x0 x1 x2 ... xn --  ) DEPTH 0 DO DROP LOOP ;
: REVERSESTACK ( xn-1 xn-2 ... x1 x0 n -- x0 x1 ... xn-2 xn-1 ) DEPTH 1 DO I ROLL LOOP ;
: ISFACTOR ( f n -- x ) MOD 0= ;
: SQUARE ( x -- x^2 ) DUP * ;
: 2DUP ( x0 x1-- x0 x1 x0 x1 ) OVER OVER ;
: 2DROP ( x0 x1 -- ) DROP DROP ;
: 3DROP ( x0 x1 x2 -- ) DROP DROP DROP ;
: */ ( x0 x1 x2 -- {x0*x1}/x2 ) ROT * SWAP / ;
: 2* ( x -- 2x ) 2 * ;
: 2/ ( x -- x/2 ) 2 / ;
: /MOD 2DUP / -ROT MOD ;
: */MOD -ROT * SWAP /MOD ;
: ?DUP ( x -- x or x -- x x ) DUP 0<> IF DUP THEN ;
: 0<> ( x -- flag) 0= INVERT ;
: 1+ ( x -- x+1 ) 1 + ;
: 1- ( x -- x-1 ) 1 - ;
: <> ( x0 x1 -- flag ) = INVERT ;
: NEGATE ( x -- -x ) 0 SWAP - ;
: 2R> R> R> SWAP ;
: 2>R  SWAP >R >R ;
: 2R@ R> R> 2DUP >R >R SWAP ;