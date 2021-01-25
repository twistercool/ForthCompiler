

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

define void @Stack_Function_QUADRATIC(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %return_stack, i32 %top_0)
  %top_1 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_1)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_2)
  %top_3 = call i32 @Stack_Pop(%stackType* %stack)
  %second_4 = call i32 @Stack_Pop(%stackType* %stack)
  %third_5 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_4)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_3)
  call void @Stack_PushInt(%stackType* %stack, i32 %third_5)
  %top_6 = call i32 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %return_stack, i32 %top_6)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_6)
  %top_7 = call i32 @Stack_Pop(%stackType* %stack)
  %second_8 = call i32 @Stack_Pop(%stackType* %stack)
  %product_9 = mul i32 %second_8, %top_7
  call void @Stack_PushInt(%stackType* %stack, i32 %product_9)
  %top_10 = call i32 @Stack_Pop(%stackType* %stack)
  %second_11 = call i32 @Stack_Pop(%stackType* %stack)
  %added_12 = add i32 %second_11, %top_10
  call void @Stack_PushInt(%stackType* %stack, i32 %added_12)
  %top_13 = call i32 @Stack_Pop(%stackType* %return_stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_13)
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  %second_15 = call i32 @Stack_Pop(%stackType* %stack)
  %product_16 = mul i32 %second_15, %top_14
  call void @Stack_PushInt(%stackType* %stack, i32 %product_16)
  %top_17 = call i32 @Stack_Pop(%stackType* %stack)
  %second_18 = call i32 @Stack_Pop(%stackType* %stack)
  %added_19 = add i32 %second_18, %top_17
  call void @Stack_PushInt(%stackType* %stack, i32 %added_19)
  ret void
}

define void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 42)
  %top_20 = call i32 @Stack_Pop(%stackType* %stack)
  call i32 @print_ASCII(i32 %top_20)
  ret void
}

define void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_26 = call i32 @Stack_Pop(%stackType* %stack)
  %second_27 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_21 = alloca i32
  store i32 %top_26, i32* %i_global_21
  br label %entry_28
entry_28:
  %i_local1_22 = load i32, i32* %i_global_21
  %isIGreater_25 = icmp sge i32 %i_local1_22, %second_27
  br i1 %isIGreater_25, label %finish_30, label %loop_29
loop_29:
  call void @Stack_Function_STAR(%stackType* %stack, %stackType* %return_stack)
  %i_local2_23 = load i32, i32* %i_global_21
  %i_local3_24 = add i32 1, %i_local2_23
  store i32 %i_local3_24, i32* %i_global_21
  br label %entry_28
finish_30:
  ret void
}

define void @Stack_Function_SQUARE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_31 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_31)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_31)
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  %top_37 = call i32 @Stack_Pop(%stackType* %stack)
  %second_38 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_32 = alloca i32
  store i32 %top_37, i32* %i_global_32
  br label %entry_39
entry_39:
  %i_local1_33 = load i32, i32* %i_global_32
  %isIGreater_36 = icmp sge i32 %i_local1_33, %second_38
  br i1 %isIGreater_36, label %finish_41, label %loop_40
loop_40:
  %top_42 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  %i_local2_34 = load i32, i32* %i_global_32
  %i_local3_35 = add i32 1, %i_local2_34
  store i32 %i_local3_35, i32* %i_global_32
  br label %entry_39
finish_41:
  %trashed_43 = call i32 @Stack_Pop(%stackType* %stack)
  ret void
}

define void @Stack_Function_TRIANGLE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_44 = call i32 @Stack_Pop(%stackType* %stack)
  %second_45 = call i32 @Stack_Pop(%stackType* %stack)
  %added_46 = add i32 %second_45, %top_44
  call void @Stack_PushInt(%stackType* %stack, i32 %added_46)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_52 = call i32 @Stack_Pop(%stackType* %stack)
  %second_53 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_47 = alloca i32
  store i32 %top_52, i32* %i_global_47
  br label %entry_54
entry_54:
  %i_local1_48 = load i32, i32* %i_global_47
  %isIGreater_51 = icmp sge i32 %i_local1_48, %second_53
  br i1 %isIGreater_51, label %finish_56, label %loop_55
loop_55:
  %i_local_57 = load i32, i32* %i_global_47
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_57)
  call void @Stack_Function_STARS(%stackType* %stack, %stackType* %return_stack)
  call i32 @printNL()
  %i_local2_49 = load i32, i32* %i_global_47
  %i_local3_50 = add i32 1, %i_local2_49
  store i32 %i_local3_50, i32* %i_global_47
  br label %entry_54
finish_56:
  ret void
}

define void @Stack_Function_TOWER(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_58 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_58)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_58)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_59 = call i32 @Stack_Pop(%stackType* %stack)
  %second_60 = call i32 @Stack_Pop(%stackType* %stack)
  %subvalue_61 = sub i32 %second_60, %top_59
  call void @Stack_PushInt(%stackType* %stack, i32 %subvalue_61)
  call void @Stack_Function_TRIANGLE(%stackType* %stack, %stackType* %return_stack)
  call void @Stack_Function_SQUARE(%stackType* %stack, %stackType* %return_stack)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 2)
  call void @Stack_PushInt(%stackType* %stack, i32 7)
  call void @Stack_PushInt(%stackType* %stack, i32 9)
  call void @Stack_PushInt(%stackType* %stack, i32 3)
  call void @Stack_Function_QUADRATIC(%stackType* %stack, %stackType* %return_stack)
  %top_62 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_63 = call i32 @printInt(i32 %top_62)
  call i32 @printNL()
  call void @Stack_PushInt(%stackType* %stack, i32 6)
  call void @Stack_Function_TOWER(%stackType* %stack, %stackType* %return_stack)

  ret i32 0
}
