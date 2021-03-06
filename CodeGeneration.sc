/*  AUTHOR: Pierre Brassart
    
    This is the code generator for the Forth Compiler project

    To run a Forth .fth file, run this command in the same directory as the Forth file:

    amm <path to CodeGeneration.sc> run <fileName>

    The library will need to be in thw current working directory to be imported


    To compile a Forth .fth file to LLVM-IR without running it, run this command:

    amm CodeGeneration.sc compileFile <filenName>

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

// These operator overloads have been taken from the 6CCS2CFL module
implicit def string_inters(sc: StringContext) = new {
    def i(args: Any*): String = "  " ++ sc.s(args:_*) ++ "\n"
    def l(args: Any*): String = sc.s(args:_*) ++ ":\n"
    def m(args: Any*): String = sc.s(args:_*) ++ "\n"
}


val begin = """

; string template for a number
@.str = private constant [4 x i8] c"%d \00"
; string template for an ASCII character
@.asciiStr = private constant [4 x i8] c"%c \00"

declare void @exit(i32 %arg)

declare i64 @printf(i8*, ...)

define i64 @printInt(i64 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.str, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %t0, i64 %x) 
  ret i64 %x
}

define i64 @print_ASCII(i64 %x) 
{
  %t0 = getelementptr [4 x i8], [4 x i8]* @.asciiStr, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %t0, i64 %x) 
  ret i64 %x
}

; store the newline as a string constant
; more specifically as a constant array containing i8 integers
@.nl = constant [2 x i8] c"\0A\00"

define i64 @printNL() 
{
  %castNL = getelementptr [2 x i8], [2 x i8]* @.nl, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %castNL)
  ret i64 0
}

@.space = constant [2 x i8] c" \00"

define i64 @printSpace() 
{
  %castSpace = getelementptr [2 x i8], [2 x i8]* @.space, i32 0, i32 0
  call i64 (i8*, ...) @printf(i8* %castSpace)
  ret i64 0
}

;this is where I define the stackType, it holds the length of the stack and the stack itself (array of i64)
%stackType = type { 
  i64, ; 0: holds the current length of the stack, or the amount of elements in it 
  [256 x i64] ; 1: an array of the elements  
}

; constructor for %stackType
define void @Stack_Create_Empty(%stackType* %this) nounwind
{
  ; initialises the length to 0
  %1 = getelementptr %stackType, %stackType* %this, i32 0, i32 0
  store i64 0, i64* %1

  ; initialises the array to empty
  %2 = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %empty_stack = alloca [256 x i64]
  %loaded = load [256 x i64], [256 x i64]* %empty_stack
  store [256 x i64] %loaded, [256 x i64]* %2
  ret void
}

; returns the length of an input stack 
define i64 @Stack_GetLength(%stackType* %this) nounwind 
{
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  ret i64 %2
}

define void @Stack_IncrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  %3 = add i64 1, %2
  store i64 %3, i64* %1 
  %isOverflow = icmp eq i64 %3, 256
  br i1 %isOverflow, label %exception, label %continue
exception:
  %overflow = alloca [16 x i8] 
  store [16 x i8] c"Stack Overflow!\00", [16 x i8]* %overflow
  %str = getelementptr [16 x i8], [16 x i8]* %overflow, i64 0, i64 0
  call i64 @printNL()
  call i64 (i8*, ...) @printf(i8* %str)
  call void @exit(i32 0)
  ret void
continue:
  ret void
}

define void @Stack_DecrementLength(%stackType* %this) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %1 = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %2 = load i64, i64* %1
  %3 = sub i64 %2, 1
  store i64 %3, i64* %1
  %isUnderflow = icmp eq i64 %3, -1
  br i1 %isUnderflow, label %exception, label %continue
exception:
  %underflow = alloca [17 x i8] 
  store [17 x i8] c"Stack Underflow!\00", [17 x i8]* %underflow
  %str = getelementptr [17 x i8], [17 x i8]* %underflow, i64 0, i64 0
  call i64 @printNL()
  call i64 (i8*, ...) @printf(i8* %str)
  call void @exit(i32 0)
  ret void
continue:
  ret void
}

define void @Stack_PushInt(%stackType* %this, i64 %int) nounwind
{ 
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i64, i64* %lengthptr

  ; gets the pointer element at index %length of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %1 = getelementptr [256 x i64], [256 x i64]* %stack, i32 0, i64 %length
  ; stores the number in the given pointer
  store i64 %int, i64* %1

  call void @Stack_IncrementLength(%stackType* %this)
  ret void
}

define i64 @Stack_Pop(%stackType* %this) nounwind
{
  ; loads the length of the stack, adds one, stores it into the stackType
  %lengthptr = getelementptr %stackType, %stackType* %this , i32 0, i32 0
  %length = load i64, i64* %lengthptr
  %index = sub i64 %length, 1

  ; gets the pointer element at index %index of the array
  %stack = getelementptr %stackType, %stackType* %this, i32 0, i32 1
  %indexptr = getelementptr [256 x i64], [256 x i64]* %stack, i32 0, i64 %index
  ; loads the number from the given pointer
  %popped = load i64, i64* %indexptr

  call void @Stack_DecrementLength(%stackType* %this)
  ret i64 %popped
}
"""

val mainBegin = """

define i32 @main(i32 %argc, i8** %argv) {
  ; initialises the data stack and the return stack
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED FORTH CODE STARTS HERE


"""

val ending = """
  ; COMPILATION FINISHED
  ret i32 0
}
"""


// This compiles the definitions into functions and strings into global variables
def compile_definition(token: Token): String = token match {
  case Define(Command(id), list)  => {
    m"\ndefine void @Stack_Function_${id}(%stackType* %stack, %stackType* %return_stack) nounwind" ++
    m"{" ++
    compile_progs(list) ++
    i"ret void" ++
    m"}"
  }
  case Constant(str)  => {
    val load_constant = Fresh("load_constant")
    m"@.${str} = global i64 0" ++  
    m"\ndefine void @Stack_Function_${str}(%stackType* %stack, %stackType* %return_stack) nounwind" ++
    m"{" ++
    //push the global variable onto the stack
    i"%${load_constant} = load i64, i64* @.${str}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${load_constant})" ++
    i"ret void" ++
    m"}"
  }
  case Variable(str)  => {
    //initialises the global variables to 0
    m"@.${str} = global i64 0"
  }
  case _  => ""
}


def compile_prog(token: Token): String = token match {
  case Push(x) => {
    i";push ${x}" ++ i"call void @Stack_PushInt(%stackType* %stack, i64 ${x})"
  }
  case Command(x) => i";${x}" ++ compile_command(x)
  case Loop(list) => {
    val i_global = Fresh("i_global")
    val i_local1 = Fresh("i_local1")
    val i_local2 = Fresh("i_local2")
    val i_local3 = Fresh("i_local3")
    val isIEqual = Fresh("isIEqual")
    val top = Fresh("top")
    val second = Fresh("second")
    val entry = Fresh("entry")
    val loop = Fresh("loop")
    val finish = Fresh("finish")

    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${i_global} = alloca i64" ++
    i"store i64 %${top}, i64* %${i_global}" ++
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${i_local1} = load i64, i64* %${i_global}" ++
    i"%${isIEqual} = icmp eq i64 %${i_local1}, %${second}" ++
    i"br i1 %${isIEqual}, label %${finish}, label %${loop}" ++
    l"${loop}" ++
    compile_loop(list, i_global, "", finish) ++
    //increment i_global
    i"%${i_local2} = load i64, i64* %${i_global}" ++
    i"%${i_local3} = add i64 1, %${i_local2}" ++
    i"store i64 %${i_local3}, i64* %${i_global}" ++
    i"br label %${entry}" ++
    l"${finish}"
  } 
  case Define(x, y) => ""
  case IfThen(a, b) => {
    val if_block = Fresh("if_block")
    val else_block = Fresh("else_block")
    val isZero = Fresh("isZero")
    val top = Fresh("top")
    val if_exit = Fresh("if_exit")
    
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isZero} = icmp eq i64 %${top}, 0" ++
    i"br i1 %${isZero}, label %${else_block}, label %${if_block}" ++
    l"${if_block}" ++
    compile_progs(a) ++
    i"br label %${if_exit}" ++
    l"${else_block}" ++
    compile_progs(b) ++
    i"br label %${if_exit}" ++
    l"${if_exit}"
  }
  case PrintString(str) => {
    val string_ref = Fresh("string_ref")
    val string_ptr = Fresh("string_ptr")
    i";PRINT STRING ${str}" ++
    i"%${string_ref} = alloca [${str.length+1} x i8]" ++
    s"""  store [${str.length+1} x i8] c"${str}\\00", [${str.length+1} x i8]* %${string_ref}""" ++
    i"\n  %${string_ptr} = getelementptr [${str.length+1} x i8], [${str.length+1} x i8]* %${string_ref}, i64 0, i64 0" ++
    i"call i64 (i8*, ...) @printf(i8* %${string_ptr})"
  }
  case AssignVariable(str) => {
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"store i64 %${top}, i64* @.${str}"
  }
  case FetchVariable(str) => {
    val var_local = Fresh("var_local")
    i"%${var_local} = load i64, i64* @.${str}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${var_local})"
  }
  case Constant(str) => {
    val top = Fresh("top")
    i";constant ${str}" ++ i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"store i64 %${top}, i64* @.${str}" 
  }
  case _ => ""
}

def compile_loop(loopRoutine: List[Token], innerIndexString: String,
  outerIndexString: String, finishLabel: String): String = loopRoutine match {
  case Nil => ""
  case Push(x) :: rest => {
    i";push ${x}" ++ i"call void @Stack_PushInt(%stackType* %stack, i64 ${x})" ++ 
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("I") :: rest => {
    val i_local = Fresh("i_local")
    i";I" ++ i"%${i_local} = load i64, i64* %${innerIndexString}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${i_local})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("J") :: rest => {
    val j_local = Fresh("j_local")
    i";J" ++ i"%${j_local} = load i64, i64* %${outerIndexString}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${j_local})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command("LEAVE") :: rest => {
    i";LEAVE" ++ i"br label %${finishLabel}" ++ compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Command(x) :: rest => {
    i";${x}" ++ compile_command(x) ++ compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Loop(list) :: rest => {
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
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${newIndex_global} = alloca i64" ++
    i"store i64 %${top}, i64* %${newIndex_global}" ++
    i"br label %${entry}" ++
    l"${entry}" ++
    i"%${newIndex_local1} = load i64, i64* %${newIndex_global}" ++
    i"%${isIGreater} = icmp sge i64 %${newIndex_local1}, %${second}" ++
    i"br i1 %${isIGreater}, label %${finish}, label %${loop}" ++
    l"${loop}" ++
    compile_loop(list, newIndex_global, innerIndexString, finish) ++
    //increment newIndex_global
    i"%${newIndex_local2} = load i64, i64* %${newIndex_global}" ++
    i"%${newIndex_local3} = add i64 1, %${newIndex_local2}" ++
    i"store i64 %${newIndex_local3}, i64* %${newIndex_global}" ++
    i"br label %${entry}" ++
    l"${finish}" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case IfThen(a, b) :: rest => {
    val if_block = Fresh("if_block")
    val else_block = Fresh("else_block")
    val isZero = Fresh("isZero")
    val top = Fresh("top")
    val if_exit = Fresh("if_exit")
    
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isZero} = icmp eq i64 %${top}, 0" ++
    i"br i1 %${isZero}, label %${else_block}, label %${if_block}" ++
    l"${if_block}" ++
    compile_loop(a, innerIndexString, outerIndexString, finishLabel) ++
    i"br label %${if_exit}" ++
    l"${else_block}" ++
    compile_loop(b, innerIndexString, outerIndexString, finishLabel) ++
    i"br label %${if_exit}" ++
    l"${if_exit}" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case PrintString(str) :: rest => {
    val string_ref = Fresh("string_ref")
    val string_ptr = Fresh("string_ptr")
    i";PRINT STRING ${str}" ++
    i"%${string_ref} = alloca [${str.length+1} x i8]" ++
    s"""  store [${str.length+1} x i8] c"${str}\\00", [${str.length+1} x i8]* %${string_ref}""" ++
    i"\n  %${string_ptr} = getelementptr [${str.length+1} x i8], [${str.length+1} x i8]* %${string_ref}, i64 0, i64 0" ++
    i"call i64 (i8*, ...) @printf(i8* %${string_ptr})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case AssignVariable(str) :: rest => {
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"store i64 %${top}, i64* @.${str}" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case FetchVariable(str) :: rest => {
    val var_local = Fresh("var_local")
    i"%${var_local} = load i64, i64* @.${str}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${var_local})" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case Constant(str) :: rest => {
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"store i64 %${top}, i64* @.${str}" ++
    compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
  }
  case _ :: rest => compile_loop(rest, innerIndexString, outerIndexString, finishLabel)
}

//implements all primitves handled by the system
def compile_command(str: String): String = str.toUpperCase match {
  case "PLUS" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    val addedValue = Fresh("added")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${addedValue} = add i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${addedValue})"
  }
  case "MINUS" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    val subvalue = Fresh("subvalue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${subvalue} = sub i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${subvalue})"
  }
  case "DIV" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    val subvalue = Fresh("subvalue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${subvalue} = udiv i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${subvalue})"
  }
  case "MUL" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    val product = Fresh("product")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${product} = mul i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${product})"
  }
  case "MOD" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val modValue = Fresh("modValue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${modValue} = srem i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${modValue})"
  }
  case "DUP" => {
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})"
  }
  case "DEPTH" => {
    val length = Fresh("Length")
    i"%${length} = call i64 @Stack_GetLength(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${length})"
  }
  case "DROP" => {
    val trashed = Fresh("trashed") 
    i"%${trashed} = call i64 @Stack_Pop(%stackType* %stack)"
  }
  case "OVER" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})"
  }
  case "2OVER" => { 
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    val fourth = Fresh("fourth")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${fourth} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${fourth})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${third})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${fourth})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${third})"
  }
  case "ROT" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${third})"
  }
  case "SWAP" => {
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})"
  }
  case "2SWAP" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val third = Fresh("third")
    val fourth = Fresh("fourth")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${third} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${fourth} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${fourth})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${third})"
  }
  case "TUCK" => {
    val top = Fresh("top")
    val second = Fresh("second")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++ 
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})"
  }
  case "EMIT" => {
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call i64 @print_ASCII(i64 %${top})"
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
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isGreater} = icmp sge i64 %${top}, 0" ++
    i"br i1 %${isGreater}, label %${ifpositive}, label %${elsenegative}" ++
    l"${ifpositive}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"br label %${finish}" ++
    l"${elsenegative}" ++
    i"%${minustop} = sub i64 0, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${minustop})" ++
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
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isGreater} = icmp sge i64 %${top}, %${second}" ++
    i"br i1 %${isGreater}, label %${tophigher}, label %${secondhigher}" ++
    l"${tophigher}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"br label %${finish}" ++
    l"${secondhigher}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
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
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isSmaller} = icmp sle i64 %${top}, %${second}" ++
    i"br i1 %${isSmaller}, label %${topsmaller}, label %${secondsmaller}" ++
    l"${topsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})" ++
    i"br label %${finish}" ++
    l"${secondsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${second})" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "." => {
    val top = Fresh("top")
    val printTop = Fresh("printTop")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${printTop} = call i64 @printInt(i64 %${top})"
  }
  case "CR" => {
    i"call i64 @printNL()"
  }
  case "SPACE" => {
    i"call i64 @printSpace()"
  }
  case "0=" => {
    val top = Fresh("top")
    val equal_to_0 = Fresh("equal_to_0")
    val push_false = Fresh("push_false") 
    val push_true = Fresh("push_true")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${equal_to_0} = icmp eq i64 %${top}, 0" ++
    i"br i1 %${equal_to_0}, label %${push_true}, label %${push_false}" ++
    l"${push_true}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish}" ++
    l"${push_false}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "0LESS" => {
    val top = Fresh("top")
    val less_than_0 = Fresh("less_than_0")
    val push_false = Fresh("push_false") 
    val push_true = Fresh("push_true")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${less_than_0} = icmp slt i64 %${top}, 0" ++
    i"br i1 %${less_than_0}, label %${push_true}, label %${push_false}" ++
    l"${push_true}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish}" ++
    l"${push_false}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "0GREATER" => {
    val top = Fresh("top")
    val more_than_0 = Fresh("more_than_0")
    val push_false = Fresh("push_false") 
    val push_true = Fresh("push_true")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${more_than_0} = icmp sgt i64 %${top}, 0" ++
    i"br i1 %${more_than_0}, label %${push_true}, label %${push_false}" ++
    l"${push_true}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish}" ++
    l"${push_false}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "LESS" => { // <
    val top = Fresh("top")
    val second = Fresh("second")
    val isSmaller = Fresh("isSmaller")
    val topsmaller = Fresh("topsmaller")
    val secondsmaller = Fresh("secondsmaller")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isSmaller} = icmp sle i64 %${top}, %${second}" ++
    i"br i1 %${isSmaller}, label %${topsmaller}, label %${secondsmaller}" ++
    l"${topsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${secondsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "GREATER" => { // >
    val top = Fresh("top")
    val second = Fresh("second")
    val isSmaller = Fresh("isSmaller")
    val topsmaller = Fresh("topsmaller")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isSmaller} = icmp slt i64 %${top}, %${second}" ++
    i"br i1 %${isSmaller}, label %${topsmaller}, label %${topsmaller}" ++
    l"${topsmaller}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "=" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val isEqual = Fresh("isSmaller")
    val equal = Fresh("equal")
    val unequal = Fresh("unequal")
    val finish = Fresh("finish")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${isEqual} = icmp eq i64 %${top}, %${second}" ++
    i"br i1 %${isEqual}, label %${equal}, label %${unequal}" ++
    l"${equal}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish}" ++
    l"${unequal}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  case "GREATERR" => { // >R
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %return_stack, i64 %${top})"
  }
  case "RGREATER" => { // R>
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %return_stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})"
  }
  case "RAT" => { // R@
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %return_stack)" ++
    i"call void @Stack_PushInt(%stackType* %return_stack, i64 %${top})" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${top})"
  }
  case "INVERT" => {
    val entry_invert = Fresh("entry_invert")
    val isFalseFlag = Fresh("isFalseFlag")
    val changeToTrue = Fresh("changeToTrue")
    val changeToFalse = Fresh("changeToFalse")
    val finish_invert = Fresh("finish_invert")
    val top = Fresh("top")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"br label %${entry_invert}" ++
    l"${entry_invert}" ++
    i"%${isFalseFlag} = icmp eq i64 %${top}, 0" ++
    i"br i1 %${isFalseFlag}, label %${changeToTrue}, label %${changeToFalse}" ++
    l"${changeToTrue}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 -1)" ++
    i"br label %${finish_invert}" ++
    l"${changeToFalse}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 0)" ++
    i"br label %${finish_invert}" ++
    l"${finish_invert}"
  }
  case "OR" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val orValue = Fresh("orValue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${orValue} = or i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${orValue})"
  }
  case "XOR" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val xorValue = Fresh("xorValue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${xorValue} = xor i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${xorValue})"
  }
  case "AND" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val andValue = Fresh("andValue")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${andValue} = and i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${andValue})"
  }
  case "LSHIFT" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val shifted = Fresh("shifted")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${shifted} = shl i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${shifted})"
  }
  case "RSHIFT" => {
    val top = Fresh("top")
    val second = Fresh("second")
    val shifted = Fresh("shifted")
    i"%${top} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${second} = call i64 @Stack_Pop(%stackType* %stack)" ++
    i"%${shifted} = lshr i64 %${second}, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i64 %${shifted})"
  }
  case cmd => {
    i"call void @Stack_Function_${cmd}(%stackType* %stack, %stackType* %return_stack)"
  }
}


def compile_definitions(prog: List[Token]): String = {
  (for (token <- prog) yield {
    compile_definition(token)
  }).mkString("")
}

def compile_progs(prog: List[Token]): String = {
  (for (token <- prog) yield {
    compile_prog(token)
  }).mkString("")
}

def compile(prog: List[Token]): String = {
  begin ++ 
  compile_definitions(prog) ++
  mainBegin ++
  compile_progs(prog) ++
  ending
}

import ammonite.ops._

/*
  This function is callable from the command line
  It reads the library file, reads the input file and compiles them
  If fit doesn't find the library file, it doesn't append anything to the input file
  If it doesn't find the input file, it returns an exception

  It compiles everything into a new folder that contains 3 files, the .ll containing
  the LLVM, the .o file and the runnable file without an extension name

  @param = name of the file to compile
*/
@main
def compileFile(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    //adds the CodeGeneration.fth Forth code
    var ast: List[Token] = List()
    try {
      val generationCode = os.read(os.pwd / "CodeGeneration.fth")
      ast = tree(generationCode.concat(os.read(path).concat(" ")))
    }
    catch {
      case e: Exception => {
        ast = tree(os.read(path).concat(" "))
      }
    }
    val code = compile(ast)

    if (!os.isDir(os.pwd / file)) os.makeDir(os.pwd / file)
    
    os.write.over(os.pwd / file / (file ++ ".ll"), code)
    os.proc("llc", "-O3", "-filetype=obj", file / (file ++ ".ll")).call()
    os.proc("clang", file /(file ++ ".o"), "-o", file / file).call()
    println("File Compiled")
}

@main
def run(fname: String) = {
    val path = os.pwd / fname
    val file = fname.stripSuffix("." ++ path.ext)
    compileFile(fname)
    os.proc("./" ++ file ++ "/" ++ file).call(stdout = os.Inherit)
    println(s" ok")
}

@main
def timeCompile(fname: String) = timer{ compileFile(fname) }

@main
def timeRun(fname: String) = timer{ run(fname) }

@main
def timeRunOnly(fname: String) = {
    val path = os.pwd / fname 
    val file = fname.stripSuffix("." ++ path.ext)
    compileFile(fname)
    print("\n")
    timer{
      os.proc("./" ++ file ++ "/" ++ file).call(stdout = os.Inherit)
    }
}
