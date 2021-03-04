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
case class PrintString(str: String) extends Node
case class Variable(str: String) extends Node
case class FetchVariable(str: String) extends Node
case class AssignVariable(str: String) extends Node
case class Constant(str: String) extends Node
case object Comment extends Node
case object Whitespace extends Node

def command[_: P]: P[Command] = P(
                    ("+"|"-"|"*"|"/"|"*/MOD"|"/MOD"|"*/MOD"|".").!.map{ str => Command(str) } | 
                    (">R"|"R>"|"R@").!.map{ str => Command(str) } |
                    ("0<>"|"<>"|"<"|"="|">"|"0<"|"0="|"0>").!.map{ str => Command(str) } |
                    ("1+"|"1-"|"?DUP").!.map{ str => Command(str) }
)
def number[_: P]: P[Push] = P(
    (("-".? ~ CharIn("1-9") ~ CharIn("0-9").rep).! ~ white )
        .map{ case (x, y) => Push(x.toInt) } | 
    ("0" ~ white)
        .map{ x => Push(0) } |
    ("[CHAR]" ~/ white ~ (CharIn("!-~").rep(1).!))
        .map{ case (w, x) => Push(x(0).toInt) }
)
def str[_: P]: P[PrintString] = P(
    (".\" " ~ (!" \"" ~ AnyChar).rep.! ~ " \"").map{ x => PrintString(x) }
)
def comment[_: P]: P[Node] = P(
    (("(" ~ (!")" ~ AnyChar).rep ~ ")").! | 
    ("\\" ~ (!("\n" | "\r\n") ~ AnyChar).rep))
        .map{ _ => Comment }
)
def white[_: P]: P[Node] = P(
    (CharIn(" \r\n\t")).rep(1)
        .map{ _ => Whitespace }
)
def idParser[_: P]: P[Command] = P(
    !("LOOP" | "THEN" | "ELSE" | "IF" | "VARIABLE"| "CONSTANT" | "DO" | number) ~ 
        (CharIn("A-Za-z0-9_?").rep(1)).!
        .map{ x => Command(x.toUpperCase) }
)
def defineVariable[_: P]: P[Variable] = P(
    ("VARIABLE" ~ white ~ idParser).map{ case (w, Command(x)) => Variable(x) }
)
def fetchVariable[_: P]: P[FetchVariable] = P(
    (idParser ~ white ~ "@").map{ case (Command(x), w) => FetchVariable(x) }
)
def assignVariable[_: P]: P[AssignVariable] = P(
    (idParser ~ white ~ "!")
        .map{ case (Command(id), _) => AssignVariable(id) }
)
def defineConstant[_: P]: P[Constant] = P(
    ("CONSTANT" ~ white ~ idParser).map{ case (w, Command(x)) => Constant(x) }
)
def definition[_: P]: P[Define] = P(
    (":" ~ white ~/ idParser ~ subroutine ~ ";")
        .map{ case (w, x, y) => Define(x, y) }
)
def subroutine[_: P]: P[List[Node]] = P(
    ((str | comment | fetchVariable | assignVariable | number | loop | command | white | idParser | ifElse).rep(1))
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)
def loop[_: P]: P[Loop] = P(
    ("DO" ~ white ~/ subroutine ~ "LOOP")
        .map{ case (w, x) => Loop(x) }
)
def ifElse[_: P]: P[IfElse] = P(
    ("IF" ~ white ~ subroutine ~ "THEN")
        .map{ case (w, x) => IfElse(x, List()) } |
    ("IF" ~ white ~/ subroutine ~ "ELSE" ~/ subroutine ~ "THEN")
        .map{ case (w, x, y) => IfElse(x, y) }
)
def program[_: P]: P[List[Node]] = P(
    (defineConstant | defineVariable | fetchVariable | assignVariable | str | definition |
    white | ifElse | comment | number | loop | command | idParser).rep(1)
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)



// This function takes as input a string
// and attempts to parse it with the grammar defined above. If it fails, it prints an error message,
// else, it returns the parsed input as a list of nodes
def tree(input: String): List[Node] = {
    parse(input, program(_)) match {
        case Parsed.Success(list, nb) => list
        case Parsed.Failure(list, nb, extra) => {
            println(s"parsing error at line ${nb}")
            println(Parsed.Failure(list, nb, extra))
            List()
        }
    }
}

def timer[T](function: => T): T = {
    val timeStamp0 = System.nanoTime()
    val result = function
    val timeStamp1 = System.nanoTime()
    println("Elapsed time: " + (timeStamp1 - timeStamp0) + "ns")
    result
}



@main
def timeParse(fname: String) = {
    timer{
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path).concat(" "))
    }
}

@main
def parseFile(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path).concat(" "))
    println(ast)
}



