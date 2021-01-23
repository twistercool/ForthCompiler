

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

define void @Stack_Function_DAB(%stackType* %stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_5 = call i32 @Stack_Pop(%stackType* %stack)
  %second_6 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_0 = alloca i32
  store i32 %top_5, i32* %i_global_0
  br label %entry_7
entry_7:
  %i_local1_1 = load i32, i32* %i_global_0
  %isIGreater_4 = icmp sge i32 %i_local1_1, %second_6
  br i1 %isIGreater_4, label %finish_9, label %loop_8
loop_8:
  call void @Stack_PushInt(%stackType* %stack, i32 10)
  call void @Stack_PushInt(%stackType* %stack, i32 6)
  %top_15 = call i32 @Stack_Pop(%stackType* %stack)
  %second_16 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_10 = alloca i32
  store i32 %top_15, i32* %newIndex_global_10
  br label %entry_17
entry_17:
  %newIndex_local1_11 = load i32, i32* %newIndex_global_10
  %isIGreater_14 = icmp sge i32 %newIndex_local1_11, %second_16
  br i1 %isIGreater_14, label %finish_19, label %loop_18
loop_18:
  call void @Stack_PushInt(%stackType* %stack, i32 15)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  %top_25 = call i32 @Stack_Pop(%stackType* %stack)
  %second_26 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_20 = alloca i32
  store i32 %top_25, i32* %newIndex_global_20
  br label %entry_27
entry_27:
  %newIndex_local1_21 = load i32, i32* %newIndex_global_20
  %isIGreater_24 = icmp sge i32 %newIndex_local1_21, %second_26
  br i1 %isIGreater_24, label %finish_29, label %loop_28
loop_28:
  call void @Stack_PushInt(%stackType* %stack, i32 20)
  call void @Stack_PushInt(%stackType* %stack, i32 16)
  %top_35 = call i32 @Stack_Pop(%stackType* %stack)
  %second_36 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_30 = alloca i32
  store i32 %top_35, i32* %newIndex_global_30
  br label %entry_37
entry_37:
  %newIndex_local1_31 = load i32, i32* %newIndex_global_30
  %isIGreater_34 = icmp sge i32 %newIndex_local1_31, %second_36
  br i1 %isIGreater_34, label %finish_39, label %loop_38
loop_38:
  %i_local_40 = load i32, i32* %newIndex_global_30
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_40)
  %top_41 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_42 = call i32 @printInt(i32 %top_41)
  %newIndex_local2_32 = load i32, i32* %newIndex_global_30
  %newIndex_local3_33 = add i32 1, %newIndex_local2_32
  store i32 %newIndex_local3_33, i32* %newIndex_global_30
  br label %entry_37
finish_39:
  %newIndex_local2_22 = load i32, i32* %newIndex_global_20
  %newIndex_local3_23 = add i32 1, %newIndex_local2_22
  store i32 %newIndex_local3_23, i32* %newIndex_global_20
  br label %entry_27
finish_29:
  %newIndex_local2_12 = load i32, i32* %newIndex_global_10
  %newIndex_local3_13 = add i32 1, %newIndex_local2_12
  store i32 %newIndex_local3_13, i32* %newIndex_global_10
  br label %entry_17
finish_19:
  %i_local2_2 = load i32, i32* %i_global_0
  %i_local3_3 = add i32 1, %i_local2_2
  store i32 %i_local3_3, i32* %i_global_0
  br label %entry_7
finish_9:
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 5)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_48 = call i32 @Stack_Pop(%stackType* %stack)
  %second_49 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_43 = alloca i32
  store i32 %top_48, i32* %i_global_43
  br label %entry_50
entry_50:
  %i_local1_44 = load i32, i32* %i_global_43
  %isIGreater_47 = icmp sge i32 %i_local1_44, %second_49
  br i1 %isIGreater_47, label %finish_52, label %loop_51
loop_51:
  call void @Stack_Function_DAB(%stackType* %stack)
  %i_local2_45 = load i32, i32* %i_global_43
  %i_local3_46 = add i32 1, %i_local2_45
  store i32 %i_local3_46, i32* %i_global_43
  br label %entry_50
finish_52:

  ret i32 0
}
