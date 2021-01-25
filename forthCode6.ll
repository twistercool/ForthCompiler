

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


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 10)
  call void @Stack_PushInt(%stackType* %stack, i32 10)
  br label %entry_3
entry_3:
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  %second_1 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_2 = icmp eq i32 %top_0, %second_1
  br i1 %isSmaller_2, label %equal_4, label %unequal_5
equal_4:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_6
unequal_5:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_6
finish_6:
  %top_12 = call i32 @Stack_Pop(%stackType* %stack)
  br label %entry_invert_7
entry_invert_7:
  %isFalseFlag_8 = icmp eq i32 %top_12, 0
  br i1 %isFalseFlag_8, label %changeToTrue_9, label %changeToFalse_10
changeToTrue_9:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_invert_11
changeToFalse_10:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_invert_11
finish_invert_11:
  %top_16 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_15 = icmp eq i32 %top_16, 0
  br i1 %isZero_15, label %else_block_14, label %if_block_13
if_block_13:
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  %top_18 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_19 = call i32 @printInt(i32 %top_18)
  br label %if_exit_17
else_block_14:
  call void @Stack_PushInt(%stackType* %stack, i32 25)
  %top_20 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_21 = call i32 @printInt(i32 %top_20)
  br label %if_exit_17
if_exit_17:

  ret i32 0
}
