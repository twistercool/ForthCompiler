

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

@.space = constant [2 x i8] c" \00"

define i32 @printSpace() 
{
  %castSpace = getelementptr [2 x i8], [2 x i8]* @.space, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %castSpace)
  ret i32 0
}

;this is where I define the stackType, it holds the length of the stack and the stack itself (array of i32)
%stackType = type { 
  i32, ; 0: holds the current length of the stack, or the amount of elements in it 
  [100 x i32] ; 1: an array of the elements  
}

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

; returns the length of an input stack 
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
@.DATA = global i32 0
@.NB = global i32 0
@.TWENTY = global i32 0

define void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i32, i32* @.TWENTY
  call void @Stack_PushInt(%stackType* %stack, i32 %load_constant_0)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 4)
  %top_1 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_1, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 12)
  %top_2 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_2, i32* @.DATA
  %var_local_3 = load i32, i32* @.DATA
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_3)
  %top_4 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_5 = call i32 @printInt(i32 %top_4)
  %var_local_6 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_6)
  %top_7 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_8 = call i32 @printInt(i32 %top_7)
  call void @Stack_PushInt(%stackType* %stack, i32 543)
  %top_9 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_9, i32* @.NB
  %var_local_10 = load i32, i32* @.NB
  call void @Stack_PushInt(%stackType* %stack, i32 %var_local_10)
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_12 = call i32 @printInt(i32 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i32 20)
  %top_13 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_13, i32* @.TWENTY
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_15 = call i32 @printInt(i32 %top_14)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_16 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_17 = call i32 @printInt(i32 %top_16)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_18 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_19 = call i32 @printInt(i32 %top_18)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  call void @Stack_Function_TWENTY(%stackType* %stack, %stackType* %return_stack)
  %top_20 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_21 = call i32 @printInt(i32 %top_20)
  %top_22 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_23 = call i32 @printInt(i32 %top_22)

  ret i32 0
}
