/*  Author: Pierre Brassart

    This the code of the Compiler Project.
    This file creates an Abstract Syntax Tree for Forth Code.
    It requires the Ammonite REPL and the Scala Language to be installed.
    The Scala language requires the Java Virtual Machine in order to run.
    To get the AST of a forth file (.fth), input the following command in the same directory as this file:

    amm Parser.sc Parserfile <Filename.fth>
*/


import fastparse._, NoWhitespace._

abstract class Token
case class Push(value: Int) extends Token
case class Command(cmd: String) extends Token
case class Define(id: Command, subroutine: List[Token]) extends Token
case class Loop(subroutine: List[Token]) extends Token
case class IfThen(trueSubroutine: List[Token], falseSubroutine: List[Token]) extends Token
case class PrintString(str: String) extends Token
case class Variable(str: String) extends Token
case class FetchVariable(str: String) extends Token
case class AssignVariable(str: String) extends Token
case class Constant(str: String) extends Token
case object Comment extends Token
case object Whitespace extends Token

// The grammar of the parser is defined below:
def number[_: P]: P[Push] = P(
    (("-".? ~ CharIn("0-9").rep(1)).! ~ white )
        .map{ case (x, _) => Push(x.toInt) } | 
    (("[CHAR]"|"CHAR") ~ white ~ (CharIn("!-~").rep(1).!))
        .map{ case (_, x) => Push(x(0).toInt) }
)
def str[_: P]: P[PrintString] = P(
    (".\" " ~ (!"\"" ~ AnyChar).rep.! ~ "\"").map{ str => PrintString(str) }
)
def comment[_: P]: P[Token] = P(
    (("(" ~ (!")" ~ AnyChar).rep ~ ")").! | 
    ("\\" ~ (!("\n" | "\r\n") ~ AnyChar).rep))
        .map{ _ => Comment }
)
def white[_: P]: P[Token] = P(
    (CharIn(" \r\n\t")).rep(1)
        .map{ _ => Whitespace }
)
def idParser[_: P]: P[Command] = P(
    (!("LOOP" | "THEN" | "ELSE" | "IF" | "VARIABLE"| "CONSTANT" | "DO" | number) ~ 
        (!CharIn("\"\\:;() \r\n\t") ~ AnyChar).rep(1).! ~ white)
        .map{ case(x, _) => Command(x.toUpperCase.replace("/", "DIV").replace("*", "MUL")
                .replace("?", "QMARK").replace(">", "GREATER").replace("<", "LESS")
                .replace("+", "PLUS").replace("-", "MINUS").replace("@","AT")) }
)
def defineVariable[_: P]: P[Variable] = P(
    ("VARIABLE" ~ white ~ idParser)
        .map{ case (w, Command(x)) => Variable(x) }
)
def fetchVariable[_: P]: P[FetchVariable] = P(
    (idParser ~ "@")
        .map{ case Command(x) => FetchVariable(x) }
)
def assignVariable[_: P]: P[AssignVariable] = P(
    (idParser ~ "!")
        .map{ case Command(id) => AssignVariable(id) }
)
def defineConstant[_: P]: P[Constant] = P(
    ("CONSTANT" ~ white ~ idParser).map{ case (w, Command(x)) => Constant(x) }
)
def definition[_: P]: P[Define] = P(
    (":" ~ white ~ idParser ~ subroutine ~ ";")
        .map{ case (w, x, y) => Define(x, y) }
)
def subroutine[_: P]: P[List[Token]] = P(
    ((str | comment | fetchVariable | assignVariable | number | loop | white | idParser | ifThen).rep(1))
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)
def loop[_: P]: P[Loop] = P(
    ("DO" ~ subroutine ~ "LOOP")
        .map{ x => Loop(x) }
)
def ifThen[_: P]: P[IfThen] = P(
    ("IF" ~ subroutine ~ "THEN")
        .map{ x => IfThen(x, List()) } |
    ("IF" ~ subroutine ~ "ELSE" ~ subroutine ~ "THEN")
        .map{ case (x, y) => IfThen(x, y) }
)
def program[_: P]: P[List[Token]] = P(
    ((defineConstant | defineVariable | fetchVariable | assignVariable | str | definition |
    white | ifThen | comment | number | loop | idParser).rep(1) ~ End)
        .map{ x => x.toList.filter({case Comment => false case Whitespace => false case _ => true}) }
)



// This function takes as input a string
// and attempts to parse it with the grammar defined above. If it fails, it prints an error message,
// else, it returns the parsed input as a list of Tokens
def tree(input: String): List[Token] = {
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



