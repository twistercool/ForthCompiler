/*  AUTHOR: Pierre Brassart
    
    This is the code generator for the Forth Compiler project

    To run a Forth .fth file, run this command:

    amm CodeGeneration.sc run <fileName>


    To compile a Forth .fth file to LLVM-IR without running it, run this command:

    amm CodeGeneration.sc write <filenName>

*/

import $file.Parser, Parser._

// for generating new labels
var counter = -1

def Fresh(x: String) = {
  counter += 1
  x ++ "_" ++ counter.toString()
}


// convenient string interpolations 
// for instructions, labels and methods
import scala.language.implicitConversions
import scala.language.reflectiveCalls

implicit def string_inters(sc: StringContext) = new {
    def i(args: Any*): String = "  " ++ sc.s(args:_*) ++ "\n"
    def l(args: Any*): String = sc.s(args:_*) ++ ":\n"
    def m(args: Any*): String = sc.s(args:_*) ++ "\n"
}


val prelude = """

; string template for a number
@.str = private constant [4 x i8] c"%d \00"
; string template for an ASCII character
@.asciiStr = private constant [4 x i8] c"%c \00"

declare i32 @printf(i8*, ...)

define i32 @printInt(i32 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.str, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

define i32 @print_ASCII(i32 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.asciiStr, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %t0, i32 %x) 
  ret i32 %x
}

; store the newline as a string constant
; more specifically as a constant array containing i8 integers
@.nl = constant [2 x i8] c"\0A\00"

define i32 @printNL() 
{
  %castNL = getelementptr [2 x i8], [2 x i8]* @.nl, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %castNL)
  ret i32 0
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
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = add i32 1, %2
  store i32 %3, i32* %1 
  ret void
}

define void @Stack_DecrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i32, i32* %1
  %3 = sub i32 %2, 1
  store i32 %3, i32* %1 
  ret void
}

define void @Stack_PushInt(%stackType* %this, i32 %int) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i32, i32* %lengthptr

  ; gets the pointer element at index %length of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %1 = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 %length
  ; stores the number in the given pointer
  store i32 %int, i32* %1

  call void @Stack_IncrementLength(%stackType* %this)
  ret void
}

define i32 @Stack_Pop(%stackType* %this) nounwind
{
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i32, i32* %lengthptr
  %negindex = sub i32 1, %length
  %index = sub i32 0, %negindex

  ; gets the pointer element at index %index of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %indexptr = getelementptr [100 x i32], [100 x i32]* %stack, i32 0, i32 %index
  ; loads the number from the given pointer
  %popped = load i32, i32* %indexptr

  call void @Stack_DecrementLength(%stackType* %this)
  ret i32 %popped
}
"""
val mainBegin = """

define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)


  ; COMPILED CODE STARTS HERE


"""

val ending = """
  ret i32 0
}
"""

def compile_definitions(prog: List[Node]): String = prog match {
  case Nil => ""
  case Define(Command(id), list) :: rest => {
    m"\ndefine void @Stack_Function_${id}(%stackType* %stack) nounwind" ++
    m"{" ++
    compile_prog(list) ++
    i"ret void" ++
    m"}" ++
    compile_definitions(rest)
  }
  case _ :: rest => compile_definitions(rest)
}


def compile_prog(prog: List[Node]): String = prog match {
  case Nil => ""
  case Push(x) :: rest => {
    i"call void @Stack_PushInt(%stackType* %stack, i32 ${x})" ++ compile_prog(rest)
  }
  case Command(x) :: rest => compile_command(x) ++ compile_prog(rest)
  case Loop(list, 0) :: rest => {
    val i_global = Fresh("i_global")
    val i_local1 = Fresh("i_local1")
    val i_local2 = Fresh("i_local2")
    val i_local3 = Fresh("i_local3")
    val isIGreater = Fresh("isIGreater")
    val top = Fresh("top")
    val second = Fresh("second")
    val entry = Fresh("entry")
    val loop = Fresh("loop")
    val finish = Fresh("finish")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${i_global} = alloca i32" ++
    i"store i32 %${top}, i32* %${i_global}" ++
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${i_local1} = load i32, i32* %${i_global}" ++
    i"%${isIGreater} = icmp sge i32 %${i_local1}, %${second}" ++
    i"br i1 %${isIGreater}, label %${finish}, label %${loop}" ++
    l"${loop}" ++
    compile_loop(list, i_global, "", finish) ++
    //increment i_global
    i"%${i_local2} = load i32, i32* %${i_global}" ++
    i"%${i_local3} = add i32 1, %${i_local2}" ++
    i"store i32 %${i_local3}, i32* %${i_global}" ++
    i"br label %${entry}" ++
    l"${finish}" ++
    compile_prog(rest)
  }
  case Define(x, y) :: rest => compile_prog(rest)
}

def compile_loop(loopRoutine: List[Node], innerIndexString: String,
  outerIndexString: String, finishLabel: String): String = loopRoutine match {
  case Nil => ""
  case Push(x) :: rest => {
    i"call void @Stack_PushInt(%stackType* %stack, i32 ${x})" ++ 
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("i") :: rest => {
    val i_local = Fresh("i_local")
    i"%${i_local} = load i32, i32* %${innerIndexString}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${i_local})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("j") :: rest => {
    val j_local = Fresh("j_local")
    i"%${j_local} = load i32, i32* %${outerIndexString}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${j_local})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("LEAVE") :: rest => {
    i"br label %${finishLabel}" ++ compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command(x) :: rest => {
    compile_command(x) ++ compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Loop(list, _) :: rest => {
    val newIndex_global = Fresh("newIndex_global")
    val newIndex_local1 = Fresh("newIndex_local1")
    val newIndex_local2 = Fresh("newIndex_local2")
    val newIndex_local3 = Fresh("newIndex_local3")
    val isIGreater = Fresh("isIGreater")
    val top = Fresh("top")
    val second = Fresh("second")
    val entry = Fresh("entry")
    val loop = Fresh("loop")
    val finish = Fresh("finish")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${newIndex_global} = alloca i32" ++
    i"store i32 %${top}, i32* %${newIndex_global}" ++
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${newIndex_local1} = load i32, i32* %${newIndex_global}" ++
    i"%${isIGreater} = icmp sge i32 %${newIndex_local1}, %${second}" ++
    i"br i1 %${isIGreater}, label %${finish}, label %${loop}" ++
    l"${loop}" ++
    compile_loop(list, newIndex_global, innerIndexString, finish) ++
    //increment newIndex_global
    i"%${newIndex_local2} = load i32, i32* %${newIndex_global}" ++
    i"%${newIndex_local3} = add i32 1, %${newIndex_local2}" ++
    i"store i32 %${newIndex_local3}, i32* %${newIndex_global}" ++
    i"br label %${entry}" ++
    l"${finish}" ++
    compile_prog(rest)
  }
}

def compile_command(str: String): String = str match {
  case "+" => { 
    val nametop = Fresh("top")
    val namesecond = Fresh("second")
    val addedValue = Fresh("added")
    i"%${nametop} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${namesecond} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${addedValue} = add i32 %${namesecond}, %${nametop}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${addedValue})"
  }
  case "-" => { 
    val nametop = Fresh("top")
    val namesecond = Fresh("second")
    val subvalue = Fresh("subvalue")
    i"%${nametop} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${namesecond} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${subvalue} = sub i32 %${namesecond}, %${nametop}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${subvalue})"
  }
  case "/" => { 
    val nametop = Fresh("top")
    val namesecond = Fresh("second")
    val subvalue = Fresh("subvalue")
    i"%${nametop} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${namesecond} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${subvalue} = udiv i32 %${namesecond}, %${nametop}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${subvalue})"
  }
  case "*" => { 
    val nametop = Fresh("top")
    val namesecond = Fresh("second")
    val product = Fresh("product")
    i"%${nametop} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${namesecond} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${product} = mul i32 %${namesecond}, %${nametop}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${product})"
  }
  case "DUP" => {
    val top = Fresh("top")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})"
  }
  case "DEPTH" => {
    val length = Fresh("Length")
    i"%${length} = call i32 @Stack_GetLength(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${length})"
  }
  case "DROP" => {
    val trashed = Fresh("trashed") 
    i"%${trashed} = call i32 @Stack_Pop(%stackType* %stack)"
  }
  case "2DROP" => {
    val trashed1 = Fresh("trashed1")
    val trashed2 = Fresh("trashed2")
    i"%${trashed1} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${trashed2} = call i32 @Stack_Pop(%stackType* %stack)"
  }
  case "3DROP" => {
    val trashed1 = Fresh("trashed1")
    val trashed2 = Fresh("trashed2")
    val trashed3 = Fresh("trashed3")
    i"%${trashed1} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${trashed2} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${trashed3} = call i32 @Stack_Pop(%stackType* %stack)"
  }
  case "OVER" => { //could optimise it by just copying the previous value but it doesn't seem very forth-like
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})"
  }
  case "2OVER" => { //same as comment above
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    val fourth = Fresh("fourth")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${fourth} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${fourth})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${third})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${fourth})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${third})"
  }
  case "ROT" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${third})"
  }
  case "-ROT" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${third})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})"
  }
  case "SWAP" => {
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})"
  }
  case "2SWAP" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    val fourth = Fresh("fourth")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${fourth} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${fourth})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${third})"
  }
  case "TUCK" => {
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})"
  }
  case "EMIT" => {
    val top = Fresh("top")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"call i32 @print_ASCII(i32 %${top})"
  }
  case "ABS" => {
    val top = Fresh("top")
    val minustop = Fresh("minustop")
    val isGreater = Fresh("isGreater")
    val entryLabel = Fresh("entryLabel")
    val ifpositive = Fresh("ifpositive")
    val elsenegative = Fresh("else")
    val finish = Fresh("finish")
    i"br label %${entryLabel}" ++
    l"${entryLabel}" ++
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${isGreater} = icmp sge i32 %${top}, 0" ++
    i"br i1 %${isGreater}, label %${ifpositive}, label %${elsenegative}" ++
    l"${ifpositive}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"br label %${finish}" ++
    l"${elsenegative}" ++
    i"%${minustop} = sub i32 0, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${minustop})" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "MAX" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val isGreater = Fresh("isGreater")
    val entry = Fresh("entry")
    val tophigher = Fresh("tophigher")
    val secondhigher = Fresh("secondhigher")
    val finish = Fresh("finish")
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${isGreater} = icmp sge i32 %${top}, %${second}" ++
    i"br i1 %${isGreater}, label %${tophigher}, label %${secondhigher}" ++
    l"${tophigher}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"br label %${finish}" ++
    l"${secondhigher}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "MIN" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val isSmaller = Fresh("isSmaller")
    val entry = Fresh("entry")
    val topsmaller = Fresh("topsmaller")
    val secondsmaller = Fresh("secondsmaller")
    val finish = Fresh("finish")
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${isSmaller} = icmp sle i32 %${top}, %${second}" ++
    i"br i1 %${isSmaller}, label %${topsmaller}, label %${secondsmaller}" ++
    l"${topsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"br label %${finish}" ++
    l"${secondsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${second})" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  // case "MOD" => {

  //   val one = stack.head
  //   val two = stack.tail.head
  //   val newStack = (two % one) :: stack.tail.tail
  //   (defs, newStack)
  // }
  case "NEGATE" => {
    val top = Fresh("top")
    val negatetop = Fresh("negatetop")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${negatetop} = sub i32 0, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${negatetop})"
  }
  case "." => {
    val top = Fresh("top")
    val printTop = Fresh("printTop")
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${printTop} = call i32 @printInt(i32 %${top})"
  }
  case "CR" => {
    i"call i32 @printNL()"
  }
  case cmd => {
    i"call void @Stack_Function_${cmd}(%stackType* %stack)"
  }
}

def compile(prog: List[Node]): String = {
  prelude ++ compile_definitions(prog) ++ mainBegin ++ compile_prog(prog) ++ ending
}

import ammonite.ops._

@main
def write(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    val ast = tree(os.read(path).concat(" "))
    val code = compile(ast)
    os.write.over(os.pwd / (file ++ ".ll"), code)
}

@main
def run(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    write(fname)
    os.proc("llc", "-filetype=obj", file ++ ".ll").call()
    os.proc("lli", file ++ ".ll").call(stdout = os.Inherit)
    println(s" ok")
}

