/*  Author: Pierre Brassart

    This the code of the Compiler Project.
    This file creates an Abstract Syntax Tree for Forth Code.
    It requires the Ammonite REPL and the Scala Language to be installed.
    The Scala language requires the Java Virtual Machine in order to run.
    To get the AST of a forth file (.fth), input the following command in the same directory as this file:

    amm Parser.sc Parserfile <Filename.fth>
*/


import fastparse._, NoWhitespace._

abstract class Node
case class Push(value: Int) extends Node
case class Command(cmd: String) extends Node
case class Define(id: Command, subroutine: List[Node]) extends Node
case class Loop(subroutine: List[Node]) extends Node
case class IfElse(trueSubroutine: List[Node], falseSubroutine: List[Node]) extends Node
case object Comment extends Node
case object Whitespace extends Node

def command[_: P]: P[Command] = P(
                    ("+"|"-"|"*"|"/"|"*/MOD"|"/MOD"|".").!.map{ str => Command(str) } | 
                    ("0<>"|"<>"|"<"|"="|">"|"0<"|"0="|"0>").!.map{ str => Command(str) }
)
def number[_: P]: P[Push] = P(
    (("-".? ~ CharIn("1-9") ~ CharIn("0-9").rep).! ~ white ).map{ case (x, y) => Push(x.toInt) }
    | ("0" ~ white).map{ x => Push(0) }
)
def comment[_: P]: P[Node] = P((("(" ~ (!")" ~ AnyChar).rep ~ ")").! | 
    ("\\" ~ (!("\n" | "\r\n") ~ AnyChar).rep))
        .map{ _ => Comment }
)
def white[_: P]: P[Node] = P(
    (CharIn(" \r\n\t")).rep(1).map{ _ => Whitespace }
)
def idParser[_: P]: P[Command] = P(
    !("LOOP" | "THEN" | "ELSE" | "IF" | number) ~ (CharIn("a-zA-Z0-9_").rep(1)).!.map{ x => Command(x) }
)
def definition[_: P]: P[Define] = P(
    (":" ~ white ~/ idParser ~ subroutine ~ ";")
    .map{ case (w, x, y) => Define(x, y) }
)
def subroutine[_: P]: P[List[Node]] = P(
    ((comment | number | loop | command | white | idParser).rep(1))
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)
def loop[_: P]: P[Loop] = P(
    ("DO" ~ white ~/ subroutine ~ "LOOP")
        .map{ case (w, x) => Loop(x) }
)
def ifNoElse[_: P]: P[IfElse] = P(
    ("IF" ~ white ~/ subroutine ~ "THEN").map{ case (w, x) => IfElse(x, List()) } |
    ("IF" ~ white ~/ subroutine ~ "ELSE" ~/ subroutine ~ "THEN").map{ case (w, x, y) => IfElse(x, y) }
)
def program[_: P]: P[List[Node]] = P(
    (definition | white | ifNoElse | comment | number | loop | command | idParser).rep(1)
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)



def tree(input: String): List[Node] = {
    (parse(input.toUpperCase, program(_)) match {
        case Parsed.Success(list, nb) => list
    })
}



@main
def testParse() = {
    val theTree = tree(": DEFINITION CLEAR  ROLL ; dabb -4 - ( this is a comment) : DEFINITION2 CLEAR 2 ABS ;  ")
    // println(theTree)
    val tree2 = tree("1 2 3 4 5 6 7 8 9 10 2OVER")
    // println(tree2)
    val tree3 = tree("DO 10 1 EMIT DEPTH DEFINEDFUCNTION LOOP")
    // println(tree3)
    val tree4 = tree("""
    1 2 3 4 /this is a test
    . . . .""")
    // println(tree4)
}

@main
def parseFile(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path).concat(" "))
    println(ast)
}



