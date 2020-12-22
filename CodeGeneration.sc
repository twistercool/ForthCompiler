import $file.Parser, Parser._

// compile function for declarations and main
// def compile_decl(d: Decl) : String = d match {
//   case Def(name, args, body) => { 
//     m"define i32 @$name (${args.mkString("i32 %", ", i32 %", "")}) {" ++
//     compile_exp(CPSi(body)) ++
//     m"}\n"
//   }
//   case Main(body) => {
//     m"define i32 @main() {" ++
//     compile_exp(CPS(body)(_ => KReturn(KNum(0)))) ++
//     m"}\n"
//   }
// }

type Def = Map[Command, List[Node]] //associates a list of commands/subroutines to a definition
type Stack = List[Int] //top of the stack is index 0


// NECESSARY TO IMPLEMENT: A WAY OF GETTING THE AMOUNT OF ELEMENTS IN THE STACK/ARRAY
// A WAY OF ADDING AN ELEMENT AT THE END OF THE ARRAY
// A WAY OF REMOVING THE LAST ELEMENT OF THE ARRAY
// A WAY OF ACCESSING ANY ELEMENT OF THE ARRAY
// A WAY OF MODIFYING ANY ELEMENT BASED ON ITS DISTANCE TO THE TOP OF THE STACK


val prelude = """

@.str = private constant [12 x i8] c"Output: %d\0A\00"

declare i32 @printf(i8*, ...)

define i32 @printInt(i32 %x) {
   %t0 = getelementptr [12 x i8], [12 x i8]* @.str, i32 0, i32 0
   call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
   ret i32 %x
}

;this is where I define the stackType, it holds the length of the stack and the stack itself (array of i32)
%stackType = type { i32, [100 x i32] }

; constructor for %stackType
define void @Stack_Create_Empty(%stackType* %this) nounwind
{
  ; initialises the length to 0
  %1 = getelementptr %stackType, %stackType* %this, i32 0, i32 0
  store i32 0, i32* %1

  ; initialises the array to empty
  %2 = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %empty_stack = alloca [100 x i32]
  %loaded = load [100 x i32], [100 x i32]* %empty_stack
  store [100 x i32] %loaded, [100 x i32]* %2
  ret void
}

; returns the length of the stack 
define i32 @Stack_GetLength(%stackType* %this) nounwind 
{
  %1 = getelementptr %stackType, %stackType* %this ,i32 0, i32 0
  %2 = load i32, i32* %1
  ret i32 %2
}

define void @Stack_IncrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackrType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = add i32 1, %2
  store i32 %3, i32* %1 
  ret void
}

define void @Stack_DecrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackrType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = sub i32 1, %2
  store i32 %3, i32* %1 
  ret void
}

define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)

  ; bullcode

  ;prints the initial length of the stack: 0
  %length = call i32 @Stack_GetLength(%stackType* %stack)
  %1 = call i32 @printInt(i32 %length)

  ;increments the length of the stack and prints the length
  call void @Stack_IncrementLength(%stackType* %stack)

  %newlength = call i32 @Stack_GetLength(%stackType* %stack)
  %2 = call i32 @printInt(i32 %newlength)

  ;decrements the length and prints out the new length
  call void @Stack_DecrementLength(%stackType* %stack)

  %newerlength = call i32 @Stack_GetLength(%stackType* %stack)
  %3 = call i32 @printInt(i32 %newerlength)



  ;end bullcode

  ; allocates a stack of 100 elements
  ;%stack = alloca [100 x i32]

  ; COMPILED CODE STARTS HERE


"""

val ending = """
  ; allocates 3 to the element at index 5 of the array 
  ;%1 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 5
  ;store i32 3, i32* %1
  ; gets the pointer element at index 5 of the array
  ;%2 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 5
  ; loads the number from the given pointer
  ;%3 = load i32, i32* %2

  ; calls print on the element %3
  ;%4 = call i32 @printInt(i32 %3)
  ret i32 0
}
"""


def compile(prog: List[Node]): String = prog match {
  case _ => prelude ++ ending
}


@main 
def printCode() = {
  println("code")
}

import ammonite.ops._

@main
def ast(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path))
    // println(compile(ast))
    println(ast)
}

@main
def write(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path))
    val code = compile(ast)
    // println(code)
    os.write.over(os.pwd / (file ++ ".ll"), code)
}

@main
def run(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    write(fname)
    os.proc("llc", "-filetype=obj", file ++ ".ll").call()
    os.proc("lli", file ++ ".ll").call(stdout = os.Inherit)
    println(s"done.")
}

