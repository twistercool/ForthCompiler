// abstract class Token 
// case class T_CMD(msg: String) extends Token
// case class T_ID(id: String) extends Token
// case class T_CMNT(comment: String) extends Token
// case class T_NUM(nb: Int) extends Token
// case object T_WHITE extends Token

// def commandParser[_: P] = P(
//                     ("CLEAR"|"DEPTH"|"DROP"|"2DROP"|"3DROP"|"DUP"|"2DUP"|"3DUP"|"OVER"|"2OVER"|
//                     "ROLL"|"ROT"|"-ROT"|"2ROT"|"SWAP"|"2SWAP"|"TUCK"|
//                     "+"|"-"|"*"|"*/"|"1+)"|"EMIT"|
//                     "1-"|"2+"|"2-"|"ABS"|"EVEN"|"MAX"|"MIN"|"MOD"|
//                     "*/MOD"|"/MOD"|"NEGATE"|"2*"|"2/"|":"|";").!.map{ str => T_CMD(str) }
// )
// def idParser[_: P] = P(
//     (CharIn("a-zA-Z")~CharIn("a-zA-Z0-9_").rep).!.map{ x => T_ID(x.toString) }
// )
// def commentParser[_: P] = P(
//     "/"~(CharIn("a-zA-Z0-9.,[]()").rep).!.map{ x => T_CMNT(x.toString) }
// )
// def numberParser[_: P] = P(
//     (CharIn("1-9")~CharIn("0-9").rep).!.map{ x => T_NUM(x.toInt) }
// )
// def whiteParser[_: P] = P(
//     (CharIn(" \n")).rep(1).map{x => T_WHITE}
// )
// def FORTHLexer[_: P] = P(
//     (commandParser|idParser|commentParser|numberParser|whiteParser)
// )
// def FORTHLexAll[_: P] = P(
//     ((FORTHLexer)~(FORTHLexer.rep(1))~End).map{x => x}
// )


// val testWhitespace = """
//    CLEAR 325 5234
// """
// val smallProg = ": STAR 42 EMIT ;"

// def findTokens(str: String) = {
//     parse(str, FORTHLexAll(_)) match {
//         case Parsed.Success(list, nb) => list
//     }
// }

// def tokenise(input: String): List[Token] = {
//     val tokenised = findTokens(input)
//     tokenised.productElement(0).asInstanceOf[Token] +: tokenised.productElement(1).asInstanceOf[List[Token]]
// }
// parse("?DUP", commandParser(_))
// parse("a_as1", idParser(_))
// parse("//sgd", commentParser(_))
// parse("6435", numberParser(_))
// parse("", whiteParser(_))

// tokenise(smallProg)