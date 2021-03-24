import $file.Parser, Parser._

type Def = Map[Command, List[Token]] //associates a list of commands/subroutines to a definition
type Stack = List[Int] //top of the stack is index 0

def eval(prog: List[Token]): (Def, Stack) = eval_prog(prog, Map(), List())

def eval_prog(prog: List[Token], defs: Def, stack: Stack): (Def, Stack) = prog match {
  case Nil => (defs, stack)
  case Push(x) :: rest => eval_prog(rest, defs, x :: stack)
  case Define(x, y) :: rest => eval_prog(rest, defs + (x -> y), stack)
  case Command(x) :: rest => {
      val commandResult = eval_command(x, defs, stack)
      eval_prog(rest, commandResult._1, commandResult._2)
  }
  case Loop(subroutine) :: rest => {
      val start = stack.head
      val end = stack.tail.head
      val (newDefs, newStack) = eval_loop(subroutine, subroutine, defs, stack.tail.tail, end, start)
      eval_prog(rest, newDefs, newStack)
  }
}

def eval_loop(loopProg: List[Token], fullLoopProg: List[Token],
    defs: Def, stack: Stack, end: Int, current: Int): (Def, Stack) = loopProg match {
    case Nil => {
        if ((current + 1) == end) (defs, stack)
        else eval_loop(fullLoopProg, fullLoopProg, defs, stack, end, current + 1)
    }
    case Command("LEAVE") :: rest => (defs, stack)
    case Command("i") :: rest => eval_loop(rest, fullLoopProg, defs, current :: stack, end, current)
    case Command(x) :: rest => {
        val (newDefs, newStack) = eval_command(x, defs, stack)
        eval_loop(rest, fullLoopProg, newDefs, newStack, end, current)
    }
    case Push(x) :: rest => {
        eval_loop(rest, fullLoopProg, defs, x :: stack, end, current)
    }
}

def eval_command(cmd: String, defs: Def, stack: Stack): (Def, Stack) = cmd match {
    case "+" => {
        val one = stack.head
        val two = stack.tail.head
        val newStack = (two + one) :: stack.tail.tail
        (defs, newStack)
    }
    case "-" => {
        val one = stack.head
        val two = stack.tail.head
        val newStack = (two - one) :: stack.tail.tail
        (defs, newStack)
    }
    case "/" => {
        val one = stack.head
        val two = stack.tail.head
        val newStack = (two / one) :: stack.tail.tail
        (defs, newStack)
    }
    case "*" => {
        val one = stack.head
        val two = stack.tail.head
        val newStack = (two * one) :: stack.tail.tail
        (defs, newStack)
    }
    case "DEPTH" => {
        (defs, stack.length :: stack)
    }
    case "DROP" => {
        val newStack = stack.tail
        (defs, newStack)
    }
    case "2DROP" => {
        val newStack = stack.tail.tail
        (defs, newStack)
    }
    case "3DROP" => {
        val newStack = stack.tail.tail.tail
        (defs, newStack)
    }
    case "DUP" => {
        val top = stack.head
        val newStack = top :: stack
        (defs, newStack)
    }
    case "2DUP" => {
        val top = stack.head
        val second = stack.tail.head
        val newStack = top :: second :: stack
        (defs, newStack)
    }
    case "3DUP" => {
        val top = stack.head
        val second = stack.tail.head
        val third = stack.tail.tail.head
        val newStack = top :: second :: third :: stack
        (defs, newStack)
    }
    case "OVER" => {
        val two = stack.tail.head
        val newStack = two :: stack
        (defs, newStack)
    }
    case "2OVER" => {
        val one = stack.tail.tail.head
        val two = stack.tail.tail.tail.head
        val newStack = one :: two :: stack
        (defs, newStack)
    }
    case "ROT" => {
        val top = stack.head
        val second = stack.tail.head
        val third = stack.tail.tail.head
        val newStack = third :: top :: second :: stack.tail.tail.tail
        (defs, newStack)
    }
    case "-ROT" => {
        val top = stack.head
        val second = stack.tail.head
        val third = stack.tail.tail.head
        val newStack = second :: third :: top :: stack.tail.tail.tail
        (defs, newStack)
    }
    case "SWAP" => {
        val top = stack.head
        val second = stack.tail.head
        val newStack = second :: top :: stack.tail.tail
        (defs, newStack)
    }
    case "2SWAP" => {
        val top = stack.head
        val second = stack.tail.head
        val third = stack.tail.tail.head
        val fourth = stack.tail.tail.tail.head
        val newStack = third :: fourth :: top :: second :: stack.tail.tail.tail.tail
        (defs, newStack)
    }
    case "TUCK" => {
        val top = stack.head
        val second = stack.tail.head
        val newStack = top :: second :: top :: stack.tail.tail
        (defs, newStack)
    }
    case "EMIT" => {
        val value = stack.head
        print(s"""${value.toChar}""")
        (defs, stack.tail)
    }
    case "ABS" => {
        val value = stack.head
        if (value < 0) (defs, -value :: stack.tail) 
        else (defs, stack)
    }
    case "MAX" => {
        val top = stack.head
        val second = stack.tail.head
        if (top > second) (defs, top :: stack.tail.tail)
        else (defs, second :: stack.tail.tail)
    }
    case "MIN" => {
        val top = stack.head
        val second = stack.tail.head
        if (top < second) (defs, top :: stack.tail.tail)
        else (defs, second :: stack.tail.tail)
    }
    case "MOD" => {
        val one = stack.head
        val two = stack.tail.head
        val newStack = (two % one) :: stack.tail.tail
        (defs, newStack)
    }
    case "NEGATE" => {
        (defs, -stack.head :: stack.tail)
    }
    case "." => {
        val value = stack.head
        println(s"""${value}""")
        (defs, stack.tail)
    }
    case "CR" => {
        println("")
        (defs, stack)
    }
    //for words that have a definition 
    case x => {
        val subroutine = defs(Command(x))
        val newStack = eval_prog(subroutine, defs, stack)._2
        (defs, newStack)
    }
}

//this program prints an F in stars on the console
val prog1 = """
: STAR 42 EMIT ;
: STARS 0 DO STAR LOOP ;
: F 5 STARS CR STAR CR 5 STARS CR STAR CR STAR CR STAR ;
F CR
"""
//this program puts all the fibonnacci numbers in the stack until the number
val prog2 = """ 
: FIB OVER OVER + ;
: FIBS 0 1 ROT 0 DO FIB LOOP ; 
40 FIBS (change the 40 for anything else)
"""

//this program prints out on the console the factorial on the input number
val prog3 = """
: FACTORIAL 
    DUP 1 DO DUP 1 - LOOP
    DEPTH 1 DO * LOOP .
;
5 FACTORIAL (just change the 5 to anything else)
"""

@main
def testInterpreter() = {
    println(eval(tree(prog1)))
    println(eval(tree(prog1)))
    println("")
    println(eval(tree(prog2)))
    println("")
    println(eval(tree(prog3)))
}

@main
def run(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path).concat(" "))
    println(eval(ast))
}

