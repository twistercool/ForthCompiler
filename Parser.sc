/*  Author: Pierre Brasasrt

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
case class Loop(subroutine: List[Node], nested: Int) extends Node

def command[_: P] = P(
                    ("DEPTH"|"DROP"|"2DROP"|"3DROP"|"DUP"|"2DUP"|"3DUP"|"OVER"|"2OVER"|
                    "ROT"|"-ROT"|"SWAP"|"2SWAP"|"TUCK"|
                    "+"|"-"|"*"|"/"|"EMIT"|"ABS"|"MAX"|"MIN"|"MOD"|
                    "*/MOD"|"/MOD"|"NEGATE"|"."|"CR").!.map{ str => Command(str) }
)
def number[_: P] = P(
    (("-".? ~ CharIn("1-9") ~ CharIn("0-9").rep).! ~ white ).map{ x => Push(x.toInt) }
    | "0".!.map{ x => Push(x.toInt) }
)
def comment[_: P] = P( ("(" ~ (!")" ~ AnyChar).rep ~ ")") | 
    ("\\" ~ (!"\n" ~ !"\r\n" ~ AnyChar).rep)
)
def white[_: P] = P(
    (CharIn(" \r\n\t")).rep(1)
)
def idParser[_: P] = P(
    !"LOOP" ~ !"THEN" ~ (CharIn("a-zA-Z") ~ CharIn("a-zA-Z0-9_").rep).!.map{ x => Command(x) }
)

def definition[_: P] = P(
    (":" ~ white ~ idParser ~ subroutine ~ ";")
    .map{ case (x, y) => Define(x, y.asInstanceOf[List[Node]]) }
)
def subroutine[_: P] = P(
    ((comment | number | loop | command | white | idParser).rep(1)).map{ x => x.filter(_ != ()) }
)
def loop[_: P] = P(
    ("DO" ~ white ~ looproutine ~ "LOOP")
    .map{ x => Loop(x.asInstanceOf[List[Node]], 0) }
)
def looproutine[_: P] = P(
    ((comment | number | nestedloop | command | white | idParser).rep(1)).map{ x => x.filter(_ != ()) }
)
def nestedloop[_: P] = P(
    ("DO" ~ white ~ nestedlooproutine ~ "LOOP")
    .map{ x => Loop(x.asInstanceOf[List[Node]], 1) }
)
def nestedlooproutine[_: P] = P(
    ((comment | number | doublenestedloop | command | white | idParser).rep(1)).map{ x => x.filter(_ != ()) }
)
def doublenestedloop[_: P] = P(
    ("DO" ~ white ~ doublenestedlooproutine ~ "LOOP")
    .map{ x => Loop(x.asInstanceOf[List[Node]], 2) }
)
def doublenestedlooproutine[_: P] = P(
    ((comment | number | command | white | idParser).rep(1)).map{ x => x.filter(_ != ()) }
)
// def if_then[_: P] = P(
//     ("IF" ~ ifroutine )
// )
// def ifroutine[_:P] = P(
//     ((!"THEN" ~ (comment | number | command | white | idParser)).rep(1)).map{ x => x.filter(_ != ()) }
// )
def program[_: P] = P(
    ((definition | comment | white | number | subroutine).rep).map{ x => x.filter(_ != ())}
)
           

//function to flatten a list of lists, since .flatten doesn't work
def f[U](l: List[U]): List[U] = l match { 
  case Nil => Nil
  case Nil :: tail => f(tail)
  case (x: List[U]) :: tail => f(x) ::: f(tail)
  case x :: tail => x :: f(tail)
}

def tree(input: String): List[Node] = {
    val parsed = parse(input, program(_)) match {
        case Parsed.Success(list, nb) => list
    }
    f(parsed.asInstanceOf[List[Node]]) //f is to flatten
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



