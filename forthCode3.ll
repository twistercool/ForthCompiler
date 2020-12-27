

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

define void @Stack_Function_FACTORIAL(%stackType* %stack) nounwind
{
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_0)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_0)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_6 = call i32 @Stack_Pop(%stackType* %stack)
  %second_7 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_1 = alloca i32
  store i32 %top_6, i32* %i_global_1
  br label %entry_8
entry_8:
  %i_local1_2 = load i32, i32* %i_global_1
  %isIGreater_5 = icmp sge i32 %i_local1_2, %second_7
  br i1 %isIGreater_5, label %finish_10, label %loop_9
loop_9:
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_12 = call i32 @Stack_Pop(%stackType* %stack)
  %second_13 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_14 = sub i32 %second_13, %top_12
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_14)
  %i_local2_3 = load i32, i32* %i_global_1
  %i_local3_4 = add i32 1, %i_local2_3
  store i32 %i_local3_4, i32* %i_global_1
  br label %entry_8
finish_10:
  %Length_15 = call i32 @Stack_GetLength(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %Length_15)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_21 = call i32 @Stack_Pop(%stackType* %stack)
  %second_22 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_16 = alloca i32
  store i32 %top_21, i32* %i_global_16
  br label %entry_23
entry_23:
  %i_local1_17 = load i32, i32* %i_global_16
  %isIGreater_20 = icmp sge i32 %i_local1_17, %second_22
  br i1 %isIGreater_20, label %finish_25, label %loop_24
loop_24:
  %top_26 = call i32 @Stack_Pop(%stackType* %stack)
  %second_27 = call i32 @Stack_Pop(%stackType* %stack)
  %product_28 = mul i32 %second_27, %top_26
  call void @Stack_PushInt(%stackType* %stack, i32 %product_28)
  %i_local2_18 = load i32, i32* %i_global_16
  %i_local3_19 = add i32 1, %i_local2_18
  store i32 %i_local3_19, i32* %i_global_16
  br label %entry_23
finish_25:
  %top_29 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_30 = call i32 @printInt(i32 %top_29)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 12)
  call void @Stack_Function_FACTORIAL(%stackType* %stack)

  ret i32 0
}
