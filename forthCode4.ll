

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
@.BL = global i32 0

define void @Stack_Function_BL(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %load_constant_0 = load i32, i32* @.BL
  call void @Stack_PushInt(%stackType* %stack, i32 %load_constant_0)
  ret void
}

define void @Stack_Function_SPACES(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
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
  call i32 @printSpace()
  %i_local2_3 = load i32, i32* %i_global_1
  %i_local3_4 = add i32 1, %i_local2_3
  store i32 %i_local3_4, i32* %i_global_1
  br label %entry_8
finish_10:
  ret void
}

define void @Stack_Function_FALSE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 0)
  ret void
}

define void @Stack_Function_TRUE(%stackType* %stack, %stackType* %return_stack) nounwind
{
  call void @Stack_PushInt(%stackType* %stack, i32 -1)
  ret void
}

define void @Stack_Function_TUCK(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_11 = call i32 @Stack_Pop(%stackType* %stack)
  %second_12 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_11)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_12)
  %top_13 = call i32 @Stack_Pop(%stackType* %stack)
  %second_14 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_14)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_13)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_14)
  ret void
}

define void @Stack_Function_NIP(%stackType* %stack, %stackType* %return_stack) nounwind
{
  %top_15 = call i32 @Stack_Pop(%stackType* %stack)
  %second_16 = call i32 @Stack_Pop(%stackType* %stack)
  call void @Stack_PushInt(%stackType* %stack, i32 %top_15)
  call void @Stack_PushInt(%stackType* %stack, i32 %second_16)
  %trashed_17 = call i32 @Stack_Pop(%stackType* %stack)
  ret void
}


define i32 @main(i32 %argc, i8** %argv) {
  ; uses the 
  %stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %stack)
  %return_stack = alloca %stackType
  call void @Stack_Create_Empty(%stackType* %return_stack)


  ; COMPILED CODE STARTS HERE


  call void @Stack_PushInt(%stackType* %stack, i32 32)
  %top_18 = call i32 @Stack_Pop(%stackType* %stack)
  store i32 %top_18, i32* @.BL
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_24 = call i32 @Stack_Pop(%stackType* %stack)
  %second_25 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_19 = alloca i32
  store i32 %top_24, i32* %i_global_19
  br label %entry_26
entry_26:
  %i_local1_20 = load i32, i32* %i_global_19
  %isIGreater_23 = icmp sge i32 %i_local1_20, %second_25
  br i1 %isIGreater_23, label %finish_28, label %loop_27
loop_27:
  %i_local_29 = load i32, i32* %i_global_19
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_29)
  %top_30 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_31 = call i32 @printInt(i32 %top_30)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_37 = call i32 @Stack_Pop(%stackType* %stack)
  %second_38 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_32 = alloca i32
  store i32 %top_37, i32* %newIndex_global_32
  br label %entry_39
entry_39:
  %newIndex_local1_33 = load i32, i32* %newIndex_global_32
  %isIGreater_36 = icmp sge i32 %newIndex_local1_33, %second_38
  br i1 %isIGreater_36, label %finish_41, label %loop_40
loop_40:
  %j_local_42 = load i32, i32* %i_global_19
  call void @Stack_PushInt(%stackType* %stack, i32 %j_local_42)
  %top_43 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_44 = call i32 @printInt(i32 %top_43)
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_50 = call i32 @Stack_Pop(%stackType* %stack)
  %second_51 = call i32 @Stack_Pop(%stackType* %stack)
  %newIndex_global_45 = alloca i32
  store i32 %top_50, i32* %newIndex_global_45
  br label %entry_52
entry_52:
  %newIndex_local1_46 = load i32, i32* %newIndex_global_45
  %isIGreater_49 = icmp sge i32 %newIndex_local1_46, %second_51
  br i1 %isIGreater_49, label %finish_54, label %loop_53
loop_53:
  %i_local_55 = load i32, i32* %newIndex_global_45
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_55)
  %top_56 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_57 = call i32 @printInt(i32 %top_56)
  %newIndex_local2_47 = load i32, i32* %newIndex_global_45
  %newIndex_local3_48 = add i32 1, %newIndex_local2_47
  store i32 %newIndex_local3_48, i32* %newIndex_global_45
  br label %entry_52
finish_54:
  %newIndex_local2_34 = load i32, i32* %newIndex_global_32
  %newIndex_local3_35 = add i32 1, %newIndex_local2_34
  store i32 %newIndex_local3_35, i32* %newIndex_global_32
  br label %entry_39
finish_41:
  %i_local2_21 = load i32, i32* %i_global_19
  %i_local3_22 = add i32 1, %i_local2_21
  store i32 %i_local3_22, i32* %i_global_19
  br label %entry_26
finish_28:
  call void @Stack_PushInt(%stackType* %stack, i32 11)
  call void @Stack_PushInt(%stackType* %stack, i32 1)
  %top_63 = call i32 @Stack_Pop(%stackType* %stack)
  %second_64 = call i32 @Stack_Pop(%stackType* %stack)
  %i_global_58 = alloca i32
  store i32 %top_63, i32* %i_global_58
  br label %entry_65
entry_65:
  %i_local1_59 = load i32, i32* %i_global_58
  %isIGreater_62 = icmp sge i32 %i_local1_59, %second_64
  br i1 %isIGreater_62, label %finish_67, label %loop_66
loop_66:
  %i_local_68 = load i32, i32* %i_global_58
  call void @Stack_PushInt(%stackType* %stack, i32 %i_local_68)
  %top_69 = call i32 @Stack_Pop(%stackType* %stack)
  %printTop_70 = call i32 @printInt(i32 %top_69)
  %i_local2_60 = load i32, i32* %i_global_58
  %i_local3_61 = add i32 1, %i_local2_60
  store i32 %i_local3_61, i32* %i_global_58
  br label %entry_65
finish_67:

  ret i32 0
}
