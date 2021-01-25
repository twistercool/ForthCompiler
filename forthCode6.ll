

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
@.reject = private constant [7 x i8] c"reject\00"
@.small = private constant [6 x i8] c"small\00"
@.medium = private constant [7 x i8] c"medium\00"
@.large = private constant [6 x i8] c"large\00"
@.extra_large = private constant [12 x i8] c"extra large\00"
@.error = private constant [6 x i8] c"error\00"

define void @Stack_Function_EGGSIZE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_0 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_0)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_0)
  call void @Stack_PushInt(%stackType* %stack, i32 18)
  br label %entry_4
entry_4:
  %top_1 = call i32 @Stack_Pop(%stackType* %stack)
  %second_2 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_3 = icmp sle i32 %top_1, %second_2
  br i1 %isSmaller_3, label %topsmaller_5, label %secondsmaller_6
topsmaller_5:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_7
secondsmaller_6:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_7
finish_7:
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_10 = icmp eq i32 %top_11, 0
  br i1 %isZero_10, label %else_block_9, label %if_block_8
if_block_8:
  ;BEGIN PRINT STRING reject
  %temp_string_13 = getelementptr [7 x i8], [7 x i8]* @.reject, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_13)
  ;END PRINT STRING reject
  br label %if_exit_12
else_block_9:
  %top_14 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_14)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_14)
  call void @Stack_PushInt(%stackType* %stack, i32 21)
  br label %entry_18
entry_18:
  %top_15 = call i32 @Stack_Pop(%stackType* %stack)
  %second_16 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_17 = icmp sle i32 %top_15, %second_16
  br i1 %isSmaller_17, label %topsmaller_19, label %secondsmaller_20
topsmaller_19:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_21
secondsmaller_20:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_21
finish_21:
  %top_25 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_24 = icmp eq i32 %top_25, 0
  br i1 %isZero_24, label %else_block_23, label %if_block_22
if_block_22:
  ;BEGIN PRINT STRING small
  %temp_string_27 = getelementptr [6 x i8], [6 x i8]* @.small, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_27)
  ;END PRINT STRING small
  br label %if_exit_26
else_block_23:
  %top_28 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_28)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_28)
  call void @Stack_PushInt(%stackType* %stack, i32 24)
  br label %entry_32
entry_32:
  %top_29 = call i32 @Stack_Pop(%stackType* %stack)
  %second_30 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_31 = icmp sle i32 %top_29, %second_30
  br i1 %isSmaller_31, label %topsmaller_33, label %secondsmaller_34
topsmaller_33:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_35
secondsmaller_34:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_35
finish_35:
  %top_39 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_38 = icmp eq i32 %top_39, 0
  br i1 %isZero_38, label %else_block_37, label %if_block_36
if_block_36:
  ;BEGIN PRINT STRING medium
  %temp_string_41 = getelementptr [7 x i8], [7 x i8]* @.medium, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_41)
  ;END PRINT STRING medium
  br label %if_exit_40
else_block_37:
  %top_42 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_42)
  call void @Stack_PushInt(%stackType* %stack, i32 27)
  br label %entry_46
entry_46:
  %top_43 = call i32 @Stack_Pop(%stackType* %stack)
  %second_44 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_45 = icmp sle i32 %top_43, %second_44
  br i1 %isSmaller_45, label %topsmaller_47, label %secondsmaller_48
topsmaller_47:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_49
secondsmaller_48:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_49
finish_49:
  %top_53 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_52 = icmp eq i32 %top_53, 0
  br i1 %isZero_52, label %else_block_51, label %if_block_50
if_block_50:
  ;BEGIN PRINT STRING large
  %temp_string_55 = getelementptr [6 x i8], [6 x i8]* @.large, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_55)
  ;END PRINT STRING large
  br label %if_exit_54
else_block_51:
  %top_56 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_56)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_56)
  call void @Stack_PushInt(%stackType* %stack, i32 30)
  br label %entry_60
entry_60:
  %top_57 = call i32 @Stack_Pop(%stackType* %stack)
  %second_58 = call i32 @Stack_Pop(%stackType* %stack)
  %isSmaller_59 = icmp sle i32 %top_57, %second_58
  br i1 %isSmaller_59, label %topsmaller_61, label %secondsmaller_62
topsmaller_61:
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  br label %finish_63
secondsmaller_62:
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  br label %finish_63
finish_63:
  %top_67 = call i32 @Stack_Pop(%stackType* %stack)
  %isZero_66 = icmp eq i32 %top_67, 0
  br i1 %isZero_66, label %else_block_65, label %if_block_64
if_block_64:
  ;BEGIN PRINT STRING extra large
  %temp_string_69 = getelementptr [12 x i8], [12 x i8]* @.extra_large, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_69)
  ;END PRINT STRING extra large
  br label %if_exit_68
else_block_65:
  ;BEGIN PRINT STRING error
  %temp_string_70 = getelementptr [6 x i8], [6 x i8]* @.error, i32 0, i32 0
  call i32 (i8*, ...) @printf(i8* %temp_string_70)
  ;END PRINT STRING error
  br label %if_exit_68
if_exit_68:
  br label %if_exit_54
if_exit_54:
  br label %if_exit_40
if_exit_40:
  br label %if_exit_26
if_exit_26:
  br label %if_exit_12
if_exit_12:
  %trashed_71 = call i32 @Stack_Pop(%stackType* %stack)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 28)
  call void @Stack_Function_EGGSIZE(%stackType* %stack, %stackType* %return_stack)

  ret i32 0
}
