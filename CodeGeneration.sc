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

  ;%printpopped = call i32 @printInt(i32 %popped)

  call void @Stack_DecrementLength(%stackType* %this)
  ret i32 %popped
}

define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)

  ; bullcode

  ;prints the initial length of the stack: 
  ;%length = call i32 @Stack_GetLength(%stackType* %stack)
  ;%call = call i32 @printInt(i32 %length)



  ;WILL PRINT OUT A RANDOM NUMBER
  ; gets the pointer element at index 0 of the array
  ;%1 = getelementptr %stackType, %stackType* %stack, i32 0, i32 1
  ;%2 = getelementptr [100 x i32], [100 x i32]* %1, i32 0, i32 0
  ; loads the number from the given pointer
  ;%3 = load i32, i32* %2
  ; calls print on the element %3
  ;%4 = call i32 @printInt(i32 %3)

  ;pushes 70 onto the stack and 75
  ;call void @Stack_PushInt(%stackType* %stack, i32 70)
  ;call void @Stack_PushInt(%stackType* %stack, i32 75)

  ; gets the pointer element at index 0 of the array
  ;%5 = getelementptr %stackType, %stackType* %stack, i32 0, i32 1
  ;%6 = getelementptr [100 x i32], [100 x i32]* %1, i32 0, i32 0
  ; loads the number from the given pointer
  ;%7 = load i32, i32* %2
  ; calls print on the element %7
  ;%8 = call i32 @printInt(i32 %7)

  
  ;%popped1 = call i32 @Stack_Pop(%stackType* %stack)
  ;%printpopped1 = call i32 @printInt(i32 %popped1)

  ;%popped2 = call i32 @Stack_Pop(%stackType* %stack)
  ;%printpopped2 = call i32 @printInt(i32 %popped2)





  ;prints the length of the stack after pushing an i32: 
  ;%newlength = call i32 @Stack_GetLength(%stackType* %stack)
  ;%newcall = call i32 @printInt(i32 %newlength)


  ; COMPILED CODE STARTS HERE


"""

val ending = """

  ;%a = call i32 @Stack_Pop(%stackType* %stack)
  ;%b = call i32 @Stack_Pop(%stackType* %stack)
  ;%c = call i32 @Stack_Pop(%stackType* %stack)
  ;%d = call i32 @Stack_Pop(%stackType* %stack)
  

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


def compile_prog(prog: List[Node]): String = prog match {
  case Push(x) :: rest => {
    i"call void @Stack_PushInt(%stackType* %stack, i32 ${x})" ++ compile_prog(rest)
  }
  case Command(x) :: rest => compile_command(x) ++ compile_prog(rest)
  case _ => ""
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
  case "DEPTH" => {
    val length = Fresh("Length")
    i"%${length} = call i32 @Stack_GetLength(%stackType* %stack)" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${length})"
  }
  case "DROP" => {
    val trashed = Fresh("trahed") 
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
  // case "EMIT" => {
  //   val value = stack.head
  //   print(s"""${value.toChar}""")
  //   (defs, stack.tail)
  // }
  case "ABS" => {
    val top = Fresh("top")
    val minustop = Fresh("minustop")
    val compare = Fresh("compare")
    val entryLabel = Fresh("entryLabel")
    val ifpositive = Fresh("ifpositive")
    val elsenegative = Fresh("else")
    val finish = Fresh("finish")
    i"br label %${entryLabel}" ++
    l"${entryLabel}" ++
    i"%${top} = call i32 @Stack_Pop(%stackType* %stack)" ++
    i"%${compare} = icmp sge i32 %${top}, 0" ++
    i"br i1 %${compare}, label %${ifpositive}, label %${elsenegative}" ++
    l"${ifpositive}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${top})" ++
    i"br label %${finish}" ++
    l"${elsenegative}" ++
    i"%${minustop} = sub i32 0, %${top}" ++
    i"call void @Stack_PushInt(%stackType* %stack, i32 %${minustop})" ++
    i"br label %${finish}" ++
    l"${finish}"
  }
  // case "MAX" => {
  //   val top = stack.head
  //   val second = stack.tail.head
  //   if (top > second) (defs, top :: stack.tail.tail)
  //   else (defs, second :: stack.tail.tail)
  // }
  // case "MIN" => {
  //   val top = stack.head
  //   val second = stack.tail.head
  //   if (top < second) (defs, top :: stack.tail.tail)
  //   else (defs, second :: stack.tail.tail)
  // }
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
  // case "CR" => {
  //   println("")
  //   (defs, stack)
  // }
  case _ => ""
}

def compile(prog: List[Node]): String = {
  prelude ++ compile_prog(prog) ++ ending
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
    println(s"done.")
}

